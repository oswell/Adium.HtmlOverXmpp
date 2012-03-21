//
//  HtmlOverXmpp.m
//  HtmlOverXmpp
//
//  Created by Mike Oswell on 12-03-20.
//  Copyright (c) 2012 Oswell, Inc. All rights reserved.
//

#import "HtmlOverXmpp.h"
#import <AutoHyperlinks/AHHyperlinkScanner.h>
#import <AutoHyperlinks/AHMarkedHyperlink.h>

#import "AIUtilities/AIAttributedStringAdditions.h"

@implementation HtmlOverXmpp

- (void) installPlugin
{
    [[adium contentController] registerContentFilter:self ofType:AIFilterContent direction:AIFilterIncoming];    
}

- (void) uninstallPlugin
{
    [[adium contentController] unregisterContentFilter:self];
}

- (NSString *) stripHtmlFromString:(NSString *)string
{
    NSRange range;

    while ((range = [string rangeOfString:@"<img[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        string = [string stringByReplacingCharactersInRange:range withString:@""];
    while ((range = [string rangeOfString:@"<br[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        string = [string stringByReplacingCharactersInRange:range withString:@""];
    
    return string; 
}


- (NSAttributedString *)filterAttributedString:(NSAttributedString *)inAttributedString context:(id)context
{    
    if(!inAttributedString || ![inAttributedString length]) return inAttributedString;
    NSMutableAttributedString *newString = [inAttributedString mutableCopy];
    NSString *content = [self stripHtmlFromString:inAttributedString.string];
    [newString replaceCharactersInRange:NSMakeRange(0, newString.string.length) withString:content];
    
    while (YES)
    {
        NSScanner *stringScanner = [NSScanner scannerWithString:newString.mutableString];
        
        NSString *body;
        NSString *href;
        
        NSUInteger start, stop = 0;
        
        [stringScanner scanUpToString:@"<a" intoString:NULL];
        
        // If we scanned for a "a" tag but couldn't find one then we will end up at the end of the string.
        if ( stringScanner.scanLocation == newString.string.length ) {
            break;
        }
        
        start = stringScanner.scanLocation;                
        [stringScanner scanUpToString:@"href" intoString:NULL];
        [stringScanner scanString:@"href=\"" intoString:NULL];
        [stringScanner scanUpToString:@"\"" intoString:&href];                
        [stringScanner scanUpToString:@">" intoString:NULL];
        [stringScanner scanString:@">" intoString:NULL];
        [stringScanner scanUpToString:@"</a>" intoString:&body];
        [stringScanner scanString:@"</a>" intoString:NULL];            
        stop = stringScanner.scanLocation;

        NSAttributedString *linkString = [NSAttributedString attributedStringWithLinkLabel:body linkDestination:href];
        [newString replaceCharactersInRange:NSMakeRange(start, stop-start) withAttributedString:linkString];

    }
    
    return [newString autorelease];
}

- (CGFloat)filterPriority
{
	return DEFAULT_FILTER_PRIORITY;
}

@end
