//
//  ScannerViewModel.swift
//  MakeSure
//
//  Created by Macbook Pro on 30.05.2023.
//

import AVFoundation
import Foundation
import UIKit

enum ScannerSentNonitificationsSteps: Int, CaseIterable {
    case warning
    case tips
    case selection
    case send_to_all
    case visit_doctor
    case final
}

class ScannerViewModel: MainViewModel {
    
    @Published var mainViewModel: MainViewModel
    @Published var isPresentingScanner = false
    @Published var scannedCode: String?
    @Published var isLoading: Bool = false
    @Published private(set) var hasLoaded: Bool = false
    @Published var searchedUser: UserModel?
    @Published var userImage: UIImage?
    @Published var isShowUser = false
    @Published var errorMessage: String?
    @Published var testResponse: String?
    @Published var positiveTestName: String?
    
    private let friendsLinksService = FriendsLinksSupabaseService()
    private let userService = UserSupabaseService()
    private let meetingsService = MeetingSupabaseService()
    private let notificationService = NotificationsSupabaseService()
    
    private let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var photoCaptureCompletionBlock: ((UIImage?) -> Void)?
    
    @Published var session: AVCaptureSession!
    @Published var capturedImage: UIImage?
    
    private let serverService = ServerService()
    
    @Published var showSendNotificationsToContactsView = false
    @Published var notificationsCurrentStep: ScannerSentNonitificationsSteps = .warning
    @Published var highRiskOfInfectionContacts: [InfectionRiskUser] = []
    @Published var possibleRiskOfInfectionContacts: [InfectionRiskUser] = []
    @Published var riskOfInfectionUsers: [InfectionRiskUser] = []
    @Published var selectedForNotificationContactsIds: [UUID]? = []
    @Published var isLoadingHighRiskUsers: Bool = false
    @Published var isLoadingPossibleRiskUsers: Bool = false
    @Published var isSendingNotifications: Bool = false
    @Published var showPositiveTestView: Bool = false
    @Published var showNegativeTestView: Bool = false
    @Published private(set) var hasLoadedHighRiskUsers: Bool = false
    @Published private(set) var hasLoadedPossibleRiskUsers: Bool = false
    @Published var riskOfInfectionUsersImages: [UUID: UIImage] = [:]
    var notificationBtnText: String {
        switch notificationsCurrentStep {
        case .selection:
            if selectedForNotificationContactsIds == nil && possibleRiskOfInfectionContacts.count == 0 || selectedForNotificationContactsIds != nil && selectedForNotificationContactsIds!.count == possibleRiskOfInfectionContacts.count {
                return "send".localized
            } else {
                return "continue_button".localized
            }
        case .send_to_all:
            return "dismiss_button".localized
        case .visit_doctor:
            return "got_it_button".localized
        default:
            return "continue_button".localized
        }
    }
    
    enum LoadImageFor {
        case riskOfInfectionUser
    }
    
    init(mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
        self.session = captureSession
    }
    
    func notificationsMoveToNextStep() {
        if notificationsCurrentStep == .selection && isSelectedAllContactsWithPossibleRisk() {
            Task {
                await self.sendNotificationsAboutRiskOfInfection(forHighRiskUsers: false)
            }
            notificationsCurrentStep = notificationsCurrentStep.next().next()
        } else {
            if notificationsCurrentStep == .send_to_all {
                Task {
                    await self.sendNotificationsAboutRiskOfInfection(forHighRiskUsers: false)
                }
            }
            notificationsCurrentStep = notificationsCurrentStep.next()
        }
    }
    
    func notificationsMoveToPreviousStep() {
        notificationsCurrentStep = notificationsCurrentStep.previous()
    }
    
    private func isSelectedAllContactsWithPossibleRisk() -> Bool {
        if selectedForNotificationContactsIds == nil && possibleRiskOfInfectionContacts.count > 0 {
            return false
        } else if let selectedForNotificationContactsIds {
            return selectedForNotificationContactsIds.count == possibleRiskOfInfectionContacts.count
        }
        return true
    }
    
    func fetchAndDistributeContacts(testType: String) async {
        var days = 0
        switch testType {
        case "Hiv":
            days = 90
        case "Hepatitis B", "Hepatitis C":
            days = 42
        case "Syphilis":
            days = 28
        case "Gonorrhea", "Chlamydia":
            days = 14
        default:
            print("Unsupported testType: \(testType)")
        }
        
        let fetchedMeetings = await fetchMeetings()
        let dateThreshold = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        let relevantMeetings = fetchedMeetings.filter { $0.date >= dateThreshold }
        let contactIds = await fetchContactIds()
        
        let partnerIdsFromRelevantMeetings = Set(relevantMeetings.map { $0.partnerId })
        let idsNotInRelevantMeetings = contactIds.filter { !partnerIdsFromRelevantMeetings.contains($0) }
        
        await fetchUsersWithRiskOfInfectionByIds(userIds: Array(partnerIdsFromRelevantMeetings), isHighRisk: true)
        await fetchUsersWithRiskOfInfectionByIds(userIds: idsNotInRelevantMeetings, isHighRisk: false)
    }
    
    private func fetchUsersWithRiskOfInfectionByIds(userIds: [UUID], isHighRisk: Bool) async {
        guard !userIds.isEmpty else {
            return
        }
        DispatchQueue.main.async {
            if isHighRisk {
                self.isLoadingHighRiskUsers = true
            } else {
                self.isLoadingPossibleRiskUsers = true
            }
        }
        
        await withTaskGroup(of: UserModel?.self) { group in
            for id in userIds {
                group.addTask {
                    do {
                        if let user = try await self.userService.fetchUserById(id: id) {
                            return user
                        } else {
                            print("user is null with id = \(id)")
                            return nil
                        }
                    } catch {
                        print("An error occurred with fetching a user: \(error)")
                        return nil
                    }
                }
            }
            
            for await user in group {
                if let user {
                    let infectionRiskUser = InfectionRiskUser(user: user, isHighRisk: isHighRisk)
                    DispatchQueue.main.async {
                        if isHighRisk {
                            self.highRiskOfInfectionContacts.append(infectionRiskUser)
                        } else {
                            self.possibleRiskOfInfectionContacts.append(infectionRiskUser)
                        }
                        self.riskOfInfectionUsers.append(infectionRiskUser)
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            if isHighRisk {
                self.isLoadingHighRiskUsers = false
                self.hasLoadedHighRiskUsers = true
            } else {
                self.isLoadingPossibleRiskUsers = false
                self.hasLoadedPossibleRiskUsers = true
            }
        }
    }
    
    func sendNotificationsAboutRiskOfInfection(forHighRiskUsers: Bool) async {
        DispatchQueue.main.async {
            self.isSendingNotifications = true
        }
        var userIds: [UUID] = []
        if forHighRiskUsers {
            userIds = self.highRiskOfInfectionContacts.map { $0.user.id }
        } else {
            userIds = self.selectedForNotificationContactsIds ?? []
        }
        guard !userIds.isEmpty else {
            return
        }
        for id in userIds {
            var description = ""
            if forHighRiskUsers {
                description = "У кого-то из твоих недавних партнеров положительный тест на \(positiveTestName ?? "Скрытое название"). \n\nНе стоит поддаваться панике. Помни, диагноз ставит только врач и только после ряда обследований. \n\nРекомендуем как можно скорее обратиться к специалисту. "
            } else {
                description = "\(mainViewModel.user?.name ?? "Пользователь") предоставил(-а) тебе результаты своих последних тестов. "
            }
            
            let model = NotificationModel(id: UUID(), userId: id, title: forHighRiskUsers ? "Внимание! " : "Сообщение", description: description, createdAt: Date(), isNotified: false)
            do {
                try await self.notificationService.create(item: model)
            } catch {
                print("An error occurred with sendinding notification: \(error)")
            }
        }
        DispatchQueue.main.async {
            self.isSendingNotifications = false
        }
    }
    
    private func fetchMeetings() async -> [MeetingModel] {
        guard let userId else {
            print("User ID is not available!")
            return []
        }
        var fetchedMeetings: [MeetingModel] = []
        do {
            fetchedMeetings = try await meetingsService.fetchMeetingsByUserId(userId: userId)
        } catch {
            print("Error loading meetings: \(error.localizedDescription)")
        }
        return fetchedMeetings
    }
    
    private func fetchContactIds() async -> [UUID] {
        guard let userId else {
            print("User ID is not available!")
            return []
        }
        var fetchedContactsIds: [UUID] = []
        do {
            if let fetchedUser = try await userService.fetchUserById(id: userId) {
                if let contactsUsersIds = fetchedUser.contacts {
                    fetchedContactsIds = Array(contactsUsersIds)
                }
            }
        } catch {
            print("Error loading meetings: \(error.localizedDescription)")
        }
        return fetchedContactsIds
    }
    
    func loadImage(user: UserModel, for type: LoadImageFor) async {
        guard let urlStr = user.photoUrl, let url = URL(string: urlStr) else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    switch type {
                    case .riskOfInfectionUser:
                        self.riskOfInfectionUsersImages[user.id] = image
                    }
                }
            }
        } catch {
            print("Error loading image: \(error)")
        }
    }
    
    func notificationsResetData() {
        selectedForNotificationContactsIds = nil
        showSendNotificationsToContactsView = false
        highRiskOfInfectionContacts = []
        possibleRiskOfInfectionContacts = []
        notificationsCurrentStep = .warning
        riskOfInfectionUsersImages = [:]
        isLoadingHighRiskUsers = false
        isLoadingPossibleRiskUsers = false
        hasLoadedHighRiskUsers = false
        hasLoadedPossibleRiskUsers = false
        resetData(showScanner: false)
    }
    
    func setupSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified) else {
                print("Unable to access back camera!")
                return
            }

            do {
                let input = try AVCaptureDeviceInput(device: device)
                
                // Check if the session already has inputs and remove them
                if let currentInput = self.captureSession.inputs.first {
                    self.captureSession.removeInput(currentInput)
                }
                
                self.captureSession.addInput(input)
                self.captureSession.sessionPreset = .photo
                
                if self.captureSession.outputs.isEmpty {
                    self.captureSession.addOutput(self.photoOutput)
                }
                
                self.captureSession.startRunning()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func takePhoto() {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func retry() {
        capturedImage = nil
    }

    func send() {
        Task {
            DispatchQueue.main.async {
                self.isLoading = true
                self.isPresentingScanner = false
            }
            do {
                if let image = capturedImage, let imageData = image.jpegData(compressionQuality: 0.7) {
                    let response = try await serverService.sendTest(imageData: imageData)
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.hasLoaded = true
                        
                        if let error_code = response.error_code {
                            switch error_code {
                            case "0":
                                self.testResponse = "it_is_a_wrong_qr_code".localized
                            case "1":
                                self.testResponse = "test_type_not_recognized".localized
                                
                                // testing 👇
//                                Task {
//                                    await self.fetchAndDistributeContacts(testType: "Gonorrhea")
//                                    await self.sendNotificationsAboutRiskOfInfection(forHighRiskUsers: true)
//                                }
//                                self.showSendNotificationsToContactsView = true
                            case "2":
                                self.testResponse = "no_result_available".localized
                            default:
                                self.testResponse = "server_error".localized
                            }
                        } else if let result = response.result {
                            switch result {
                            case "Negative":
                                self.testResponse = "congrats_result_negative".localized
                            case "Positive":
                                self.testResponse = "result_positive_see_doctor".localized
                                
                                if let testType = response.test_type {
                                    self.positiveTestName = testType
                                    self.showPositiveTestView = true
                                    Task {
                                        await self.fetchAndDistributeContacts(testType: testType)
                                        await self.sendNotificationsAboutRiskOfInfection(forHighRiskUsers: true)
                                    }
//                                    self.showSendNotificationsToContactsView = true
                                }
                            case "Failure":
                                self.testResponse = "error_occurred_try_again".localized
                            default:
                                self.testResponse = "server_error".localized
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.errorMessage = "image_conversion_failed".localized
                    }
                }
            } catch ServerServiceError.networkError(let networkError) {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "network_error".localized
                }
                print("Network error: \(networkError)")
            } catch ServerServiceError.decodingError(let decodingError) {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "server_error".localized
                }
                print("Decoding error: \(decodingError)")
            } catch ServerServiceError.unexpectedError {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "server_error".localized
                }
                print("Unexpected error occurred.")
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "server_error".localized
                }
                print("An unknown error occurred: \(error)")
            }
            DispatchQueue.main.async {
                self.capturedImage = nil
            }
        }
    }
    
    func tearDownSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }
    
    func searchUser(id: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        Task {
            do {
                let uuid = UUID(uuidString: id) ?? UUID()
                let fetchedFriendLinksModels = try await friendsLinksService.fetchLinksById(id: uuid)
                if let friendLinkModel = fetchedFriendLinksModels.first {
                    let fetchedUser = try await userService.fetchUserById(id: friendLinkModel.userId)
                    if let fetchedUser {
                        await loadImage(urlStr: fetchedUser.photoUrl)
                        try await friendsLinksService.delete(id: friendLinkModel.id)
                        DispatchQueue.main.async {
                            self.searchedUser = fetchedUser
                            self.isLoading = false
                            self.hasLoaded = true
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.searchedUser = nil
                            self.isLoading = false
                            self.errorMessage = "unable_to_load_user".localized
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.errorMessage = "user_not_found".localized
                    }
                }
            } catch {
                print("An error occurred while searching user: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "check_internet_connection".localized
                }
            }
        }
    }
    
    func searchGlobalUser(id: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        Task {
            do {
                let uuid = UUID(uuidString: id) ?? UUID()
                if let user = try await userService.fetchUserById(id: uuid) {
                    await loadImage(urlStr: user.photoUrl)
                    DispatchQueue.main.async {
                        self.searchedUser = user
                        self.isLoading = false
                        self.hasLoaded = true
                    }
                } else {
                    DispatchQueue.main.async {
                        self.searchedUser = nil
                        self.isLoading = false
                        self.errorMessage = "user_not_found".localized
                    }
                }
            } catch {
                print("An error occurred while searching user: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "check_internet_connection".localized
                }
            }
        }
    }
    
    private func loadImage(urlStr: String?) async {
        guard let urlStr, let url = URL(string: urlStr) else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.userImage = image
                }
            }
        } catch {
            print("Error loading image: \(error)")
        }
    }
    
    func resetData(showScanner: Bool = true) {
        capturedImage = nil
        testResponse = nil
        positiveTestName = nil
        scannedCode = nil
        searchedUser = nil
        userImage = nil
        errorMessage = nil
        hasLoaded = false
        isShowUser = false
        isPresentingScanner = showScanner
        showNegativeTestView = false
        showPositiveTestView = false
        showSendNotificationsToContactsView = false
    }
}

extension ScannerViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            let uiImage = UIImage(data: imageData)
            capturedImage = uiImage
        }
    }
}
