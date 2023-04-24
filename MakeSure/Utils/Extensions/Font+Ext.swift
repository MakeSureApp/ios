//
//  Font+Ext.swift
//  MakeSure
//
//  Created by andreydem on 4/22/23.
//

import Foundation
import SwiftUI

extension Font {
    
    static func rubicBoldFont(size: CGFloat) -> Font {
        return Font.custom(CustomFontsNames.rubicBold, size: size)
    }
    
    static func rubicRegularFont(size: CGFloat) -> Font {
        return Font.custom(CustomFontsNames.rubicRegular, size: size)
    }
    
    static func rubicLightFont(size: CGFloat) -> Font {
        return Font.custom(CustomFontsNames.rubicLight, size: size)
    }
    
    static func rubicMediumFont(size: CGFloat) -> Font {
        return Font.custom(CustomFontsNames.rubicMedium, size: size)
    }
    
    static func poppinsRegularFont(size: CGFloat) -> Font {
        return Font.custom(CustomFontsNames.poppinsRegular, size: size)
    }
    
    static func poppinsLightFont(size: CGFloat) -> Font {
        return Font.custom(CustomFontsNames.poppinsLight, size: size)
    }
    
    static func poppinsMediumFont(size: CGFloat) -> Font {
        return Font.custom(CustomFontsNames.poppinsMedium, size: size)
    }
    
    static func poppinsBoldFont(size: CGFloat) -> Font {
        return Font.custom(CustomFontsNames.poppinsBold, size: size)
    }
    
    static func interLightFont(size: CGFloat) -> Font {
        return Font.custom(CustomFontsNames.interLight, size: size)
    }
    
    static func interExtraLightFont(size: CGFloat) -> Font {
        return Font.custom(CustomFontsNames.interExtraLight, size: size)
    }
    
    static func interRegularFont(size: CGFloat) -> Font {
        return Font.custom(CustomFontsNames.interRegular, size: size)
    }
    
    static func interSemiBoldFont(size: CGFloat) -> Font {
        return Font.custom(CustomFontsNames.interSemiBold, size: size)
    }
    
    static func bebasNeueBoldFont(size: CGFloat) -> Font {
        return Font.custom(CustomFontsNames.bebasNeueBold, size: size)
    }
    
}
