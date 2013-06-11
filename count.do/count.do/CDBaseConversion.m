//
//  CDBaseConversion.m
//  count.do
//
//  Created by Ali Can Bülbül on 6/11/13.
//  Copyright (c) 2013 Can Bülbül. All rights reserved.
//

#import "CDBaseConversion.h"

@implementation CDBaseConversion

// Uses the alphabet length as base.
+(NSString*) formatNumber:(NSUInteger)n usingAlphabet:(NSString*)alphabet
{
    NSUInteger base = [alphabet length];
    if (n<base){
        // direct conversion
        NSRange range = NSMakeRange(n, 1);
        return [alphabet substringWithRange:range];
    } else {
        return [NSString stringWithFormat:@"%@%@",
                
                // Get the number minus the last digit and do a recursive call.
                // Note that division between integer drops the decimals, eg: 769/10 = 76
                [self formatNumber:n/base usingAlphabet:alphabet],
                
                // Get the last digit and perform direct conversion with the result.
                [alphabet substringWithRange:NSMakeRange(n%base, 1)]];
    }
}

+(NSString*) formatNumber:(NSUInteger)n toBase:(NSUInteger)base
{
    NSString *alphabet = @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"; // 62 digits
    NSAssert([alphabet length]>=base,@"Not enough characters. Use base %ld or lower.",(unsigned long)[alphabet length]);
    return [self formatNumber:n usingAlphabet:[alphabet substringWithRange:NSMakeRange (0, base)]];
}

@end

