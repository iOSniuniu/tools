//
//  ToolUtils.m
//  拍卖行
//
//  Created by admin on 13-8-29.
//  Copyright (c) 2013年 liouly. All rights reserved.
//

#import "ToolUtils.h"
#import "ChineseString.h"
#import "pinyin.h"
#import "SvUDIDTools.h"
#include <sys/sysctl.h>
#import "NSData+Base64.h"
#import <CommonCrypto/CommonDigest.h>

#include <ifaddrs.h>
#include <arpa/inet.h>

#import <GPUImage/GPUImage.h>

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "sys/utsname.h"
#import "AFNetworking.h"
#import "Reachability.h"

#pragma mark MAC addy
@implementation ToolUtils

#pragma  mark - 文件路径

//返回Cache路径
+(NSString *)returnCachePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES);
    
    NSString *cachesDir = [paths objectAtIndex:0];
    
    return cachesDir;
}


//返回首字母数组
+(NSMutableArray *)chineseSourtOutToFirstLetter:(NSMutableArray *)array
{
    
    //Step1:初始化
    NSMutableArray *stringsToSort=array;
    
    //Step2:获取字符串中文字的拼音首字母并与字符串共同存放
    NSMutableArray *chineseStringsArray=[NSMutableArray array];
    for(int i=0;i<[stringsToSort count];i++){
        ChineseString *chineseString=[[ChineseString alloc]init];
        
        chineseString.string=[NSString stringWithString:[stringsToSort objectAtIndex:i]];
        
        if(chineseString.string==nil){
            chineseString.string=@"";
        }
        
        if(![chineseString.string isEqualToString:@""]){
            NSString *pinYinResult=[NSString string];
            for(int j=0;j<chineseString.string.length;j++){
                NSString *singlePinyinLetter=[[NSString stringWithFormat:@"%c",pinyinFirstLetter([chineseString.string characterAtIndex:j])]uppercaseString];
                
                pinYinResult=[pinYinResult stringByAppendingString:singlePinyinLetter];
            }
            chineseString.pinYin=pinYinResult;
            chineseString.firstLetter = [chineseString.pinYin substringToIndex:1];
        }else{
            chineseString.pinYin=@"";
            chineseString.firstLetter = @"";
        }
        [chineseStringsArray addObject:chineseString];
    }
    
    // Step4:把内容从ChineseString类中提取出来
    NSMutableArray *firstLetterArray = [NSMutableArray array];
    for(int i=0;i<[chineseStringsArray count];i++){
        [firstLetterArray addObject:((ChineseString*)[chineseStringsArray objectAtIndex:i]).firstLetter];
    }
    
    //返回首字母数组
    return firstLetterArray;
}

//按照key对数组进行排序
+(NSMutableArray *)sortWithDescriptor:(NSMutableArray *)arrayToSort Key:(NSString *)key
{
    NSMutableArray *chineseStringsArray = [NSMutableArray arrayWithArray:arrayToSort];
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:key ascending:YES]];
    [chineseStringsArray sortUsingDescriptors:sortDescriptors];
    
    return chineseStringsArray;
}

//获得Label的高度
+(CGFloat)heightForLabel:(UILabel *)contentLab
{
    
    CGSize size = [contentLab.text sizeWithFont:contentLab.font
                              constrainedToSize: CGSizeMake(contentLab.frame.size.width, CGFLOAT_MAX)
                                  lineBreakMode: NSLineBreakByWordWrapping];
    
    return size.height;
    
}

//获得Label的宽度
+(CGFloat)widthForLabel:(UILabel *)contentLab
{
    CGSize size = [contentLab.text sizeWithFont:contentLab.font
                              constrainedToSize:CGSizeMake(CGFLOAT_MAX, contentLab.frame.size.height)
                                  lineBreakMode:NSLineBreakByWordWrapping];
    
    return size.width;
}

//获得TextView的高度
+(CGFloat)heightForTextView:(UITextView *)textView
{
    CGSize size = [textView.text sizeWithFont:textView.font
                              constrainedToSize:CGSizeMake(textView.frame.size.width,CGFLOAT_MAX)
                                  lineBreakMode:NSLineBreakByWordWrapping];
    
    return size.width;
}

//保存数据到本地沙盒
+(void)setDataToSandboxWithPersonalInfo:(NSDictionary *)dicToSandbox
{
    NSMutableDictionary *data;
    
    //获得沙盒路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    NSString *fileName = [path stringByAppendingPathComponent:@"personal.plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:fileName];
    
    if (!dic) {
        
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm createFileAtPath:fileName contents:nil attributes:nil];
        data = [NSMutableDictionary dictionaryWithDictionary:dicToSandbox];
        [data writeToFile:fileName atomically:YES];

    }
}

//读取沙盒中的数据
+(NSDictionary *)getDataFromSanboxWithPersonalInfo
{
    //获得沙盒路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    NSString *fileName = [path stringByAppendingPathComponent:@"personal.plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:fileName];
    
    if (dic) {
        
        return dic;
        
    }else{
        
        return nil;
        
    }
}

//删除沙盒中的数据
+(void)deleteDataInSanbox
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    NSString *fileName = [path stringByAppendingPathComponent:@"personal.plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:fileName];
    
    if (dic) {
        
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:fileName error:nil];

    }

}

//判断沙盒中是否有数据
+(BOOL)isDataInSanbox
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    NSString *fileName = [path stringByAppendingPathComponent:@"personal.plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:fileName];
    
    if (dic) {
        
        return YES;
    }
    
    return NO;
}


#pragma mark - 本地缓存文件操作

+ (NSMutableArray *)listFileAtPath:(NSString *)path
{
    NSMutableArray *arrayFile = [NSMutableArray new];
    if (!path) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [paths objectAtIndex:0];
        
        NSFileManager* manager = [NSFileManager defaultManager];
        if ([manager fileExistsAtPath:path]){
            
            NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:path] objectEnumerator];
            NSString* fileName;
            
            while ((fileName = [childFilesEnumerator nextObject]) != nil){
                NSString* fileAbsolutePath = [path stringByAppendingPathComponent:fileName];
                
                NSLog(@"fileName:%@ size:%.2f", fileName, [self fileSizeAtPath:fileAbsolutePath]);
                [arrayFile addObject:fileName];
            }
        }
    }
    
    return arrayFile;
}

+ (void)deletePicAtDoc
{
    for (NSString *fileName in [self listFileAtPath:nil]) {
        
        if ([fileName containsString:@".jpg"]||[fileName containsString:@".png"]) {
            [self deleteFileWithFileName:fileName];
        }
    }
}

+ (float)documentFolderSize
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    return [ToolUtils folderSizeAtPath:path];
}

//计算指定文件夹下的文件总大小
+(float )folderSizeAtPath:(NSString*) folderPath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    float folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += (float)[self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/1024;
}

//删除指定文件夹下的文件
+(void)removeFolderWithPath:(NSString *)folderPath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:folderPath]){
        
        NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
        NSString* fileName;

        while ((fileName = [childFilesEnumerator nextObject]) != nil){
            NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
            [manager removeItemAtPath:fileAbsolutePath error:nil];
        }
    }
}

//计算指定文件的大小
+(float)fileSizeAtPath:(NSString*) filePath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return (float)[[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

//删除本地的指定文件
+(void)deleteFileWithFileName:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    NSString *file = [path stringByAppendingPathComponent:fileName];
    
    if ([fileName trim].length>0) {
        
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL fileRemoved = NO;
        
        fileRemoved = [fm removeItemAtPath:file error:nil];
        
    }
}
+ (void)showHUD:(NSString *)text andView:(UIView *)view andHUD:(MBProgressHUD *)hud
{
    [view addSubview:hud];
    hud.labelText = text;
    //    hud.dimBackground = YES;
    hud.square = YES;
    [hud show:YES];
}

+ (void)showCustomViewHUD:(NSString *)text imageName:(NSString *)image andViewController:(UIViewController*)cv
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:cv.view];
	[cv.view addSubview:HUD];
	
	// The sample image is based on the work by http://www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
	// Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
	HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:image]];
	
	// Set custom view mode
	HUD.mode = MBProgressHUDModeCustomView;
	
    //	HUD.delegate = cv;
	HUD.labelText = text;
	
	[HUD show:YES];
	[HUD hide:YES afterDelay:1];
}

+ (void)showCustomViewHUD:(NSString *)text imageName:(NSString *)image andView:(UIView *)view
{
    MBProgressHUD *HUD =[[MBProgressHUD alloc] initWithView:view];
	[view addSubview:HUD];
	
	// The sample image is based on the work by http://www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
	// Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
	HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:image]];
	
	// Set custom view mode
	HUD.mode = MBProgressHUDModeCustomView;
	
    //	HUD.delegate = cv;
	HUD.labelText = text;
	
	[HUD show:YES];
	[HUD hide:YES afterDelay:1];
}
//对字符串进行md5加密
+ (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (BOOL)checkPrice:(NSString *)str
{
    NSString * regex = @"^\\d+\\.\\d{0,}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:str];
    return isMatch;
}

+ (BOOL)checkEmail:(NSString *)str
{
    NSString * regex = @"^([a-z0-9A-Z]+[-|\\._]?)+[a-z0-9A-Z]@([a-z0-9A-Z]+(-[a-z0-9A-Z]+)?\\.)+[a-zA-Z]{2,}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:str];
    return isMatch;
}
//身份证号
+ (BOOL)accurateVerifyIDCardNumber:(NSString *)value {
    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    int length =0;
    if (!value) {
        return NO;
    }else {
        length = (int)value.length;
        
        if (length !=15 && length !=18) {
            return NO;
        }
    }
    // 省份代码
    NSArray *areasArray =@[@"11",@"12", @"13",@"14", @"15",@"21", @"22",@"23", @"31",@"32", @"33",@"34", @"35",@"36", @"37",@"41", @"42",@"43", @"44",@"45", @"46",@"50", @"51",@"52", @"53",@"54", @"61",@"62", @"63",@"64", @"65",@"71", @"81",@"82", @"91"];
    
    NSString *valueStart2 = [value substringToIndex:2];
    BOOL areaFlag =NO;
    for (NSString *areaCode in areasArray) {
        if ([areaCode isEqualToString:valueStart2]) {
            areaFlag =YES;
            break;
        }
    }
    
    if (!areaFlag) {
        return false;
    }
    
    NSRegularExpression *regularExpression;
    NSUInteger numberofMatch;
    
    int year =0;
    switch (length) {
        case 15:
            year = [value substringWithRange:NSMakeRange(6,2)].intValue +1900;
            
            if (year %4 ==0 || (year %100 ==0 && year %4 ==0)) {
                
                regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}$"
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:nil];//测试出生日期的合法性
            }else {
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}$"
                                                                        options:NSRegularExpressionCaseInsensitive
                                                                          error:nil];//测试出生日期的合法性
            }
            numberofMatch = [regularExpression numberOfMatchesInString:value
                                                               options:NSMatchingReportProgress
                                                                 range:NSMakeRange(0, value.length)];
            
            if(numberofMatch >0) {
                return YES;
            }else {
                return NO;
            }
        case 18:
            year = [value substringWithRange:NSMakeRange(6,4)].intValue;
            if (year %4 ==0 || (year %100 ==0 && year %4 ==0)) {
                
                regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}[0-9Xx]$"
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:nil];//测试出生日期的合法性
            }else {
                regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}[0-9Xx]$"
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:nil];//测试出生日期的合法性
            }
            numberofMatch = [regularExpression numberOfMatchesInString:value
                                                               options:NSMatchingReportProgress
                                                                 range:NSMakeRange(0, value.length)];
            
            if(numberofMatch >0) {
                int S = ([value substringWithRange:NSMakeRange(0,1)].intValue + [value substringWithRange:NSMakeRange(10,1)].intValue) *7 + ([value substringWithRange:NSMakeRange(1,1)].intValue + [value substringWithRange:NSMakeRange(11,1)].intValue) *9 + ([value substringWithRange:NSMakeRange(2,1)].intValue + [value substringWithRange:NSMakeRange(12,1)].intValue) *10 + ([value substringWithRange:NSMakeRange(3,1)].intValue + [value substringWithRange:NSMakeRange(13,1)].intValue) *5 + ([value substringWithRange:NSMakeRange(4,1)].intValue + [value substringWithRange:NSMakeRange(14,1)].intValue) *8 + ([value substringWithRange:NSMakeRange(5,1)].intValue + [value substringWithRange:NSMakeRange(15,1)].intValue) *4 + ([value substringWithRange:NSMakeRange(6,1)].intValue + [value substringWithRange:NSMakeRange(16,1)].intValue) *2 + [value substringWithRange:NSMakeRange(7,1)].intValue *1 + [value substringWithRange:NSMakeRange(8,1)].intValue *6 + [value substringWithRange:NSMakeRange(9,1)].intValue *3;
                int Y = S %11;
                NSString *M =@"F";
                NSString *JYM =@"10X98765432";
                M = [JYM substringWithRange:NSMakeRange(Y,1)];// 判断校验位
                if ([M isEqualToString:[value substringWithRange:NSMakeRange(17,1)]]) {
                    return YES;// 检测ID的校验位
                }else {
                    return NO;
                }
                
            }else {
                return NO;
            }
        default:
            return NO;
    }
}
+(BOOL)checkUrl:(NSString *)url
{
    
    NSString * regex = @"^\\bhttps?://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:url];
    return isMatch;
    
}

+(BOOL)checkPhone:(NSString*)checkString{
    if (checkString.length != 11)
    {
        return NO;
    }
    /**
     * 手机号码:
     * 13[0-9], 14[5,7], 15[0, 1, 2, 3, 5, 6, 7, 8, 9], 17[6, 7, 8], 18[0-9], 170[0-9]
     * 移动号段: 134,135,136,137,138,139,150,151,152,157,158,159,182,183,184,187,188,147,178,1705
     * 联通号段: 130,131,132,155,156,185,186,145,176,1709
     * 电信号段: 133,153,180,181,189,177,1700
     */
    NSString *MOBILE = @"^1(3[0-9]|4[57]|5[0-35-9]|8[0-9]|7[0678])\\d{8}$";
    /**
     * 中国移动：China Mobile
     * 134,135,136,137,138,139,150,151,152,157,158,159,182,183,184,187,188,147,178,1705
     */
    NSString *CM = @"(^1(3[4-9]|4[7]|5[0-27-9]|7[8]|8[2-478])\\d{8}$)|(^1705\\d{7}$)";
    /**
     * 中国联通：China Unicom
     * 130,131,132,155,156,185,186,145,176,1709
     */
    NSString *CU = @"(^1(3[0-2]|4[5]|5[56]|7[6]|8[56])\\d{8}$)|(^1709\\d{7}$)";
    /**
     * 中国电信：China Telecom
     * 133,153,180,181,189,177,1700
     */
    NSString *CT = @"(^1(33|53|77|8[019])\\d{8}$)|(^1700\\d{7}$)";
    
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    //   NSString * PHS = @"^(0[0-9]{2})\\d{8}$|^(0[0-9]{3}(\\d{7,8}))$";
    
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:checkString] == YES)
        || ([regextestcm evaluateWithObject:checkString] == YES)
        || ([regextestct evaluateWithObject:checkString] == YES)
        || ([regextestcu evaluateWithObject:checkString] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (UIColor *) colorWithHexString: (NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

+ (UIColor *) colorWithHexString: (NSString *)color andAlpha:(CGFloat )alpha
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:alpha];
}

//返回完整的图片路径
+(NSString *)orgianPath:(NSString *)imagePath
{
//    NSString *path = [NSString stringWithFormat:@"%@%@",BASEIMAGEURL,imagePath];
    
    return imagePath;
}

+(BOOL)isEmpty:(NSString *)string
{
    if (!string) {
        
        return YES;
        
    }
    
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([string isEqualToString:@""]) {
        
        return YES;
        
    }
    
    return NO;
    
}

#pragma mark - 日期

//返回格式化的时间
+(NSString *)dateStringFromDate:(NSDate *)date Formatter:(NSString *)formatterString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:formatterString];
    NSString *dateString = [formatter stringFromDate:date];
    
    return dateString;
}

//返回当前时间String
+(NSString *)getTimeNowWithFormatter:(NSString *)formatterString
{
    NSString* date;
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:formatterString];
    date = [formatter stringFromDate:[NSDate date]];
    NSString  *timeNow = [[NSString alloc] initWithFormat:@"%@",date];
    
    return timeNow;
}

//返回当前时间Date
+(NSDate *)getCurrentDateWithFormatter:(NSString *)formatterString
{
    NSString *currentString = [ToolUtils getTimeNowWithFormatter:formatterString];
    
    NSDate *date = [ToolUtils dateFromDateString:currentString Formatter:formatterString];
    
    return date;
}

//NSString 转 Date
+(NSDate *)dateFromDateString:(NSString *)dateString Formatter:(NSString *)matter
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:matter];
    NSDate *date = [formatter dateFromString:dateString];
    
    return date;
}

//转为北京时间
+ (NSDate *)dateForGMT:(NSDate *)data
{
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    
    NSInteger interval = [zone secondsFromGMTForDate:data];
    
    NSDate *localeDate = [data  dateByAddingTimeInterval:interval];
    
    return localeDate;
}

//时间比较
+(NSComparisonResult )checkDateTimeWithDate1:(NSDate *)date1 Data2:(NSDate *)date2
{
    switch ([date1 compare:date2]) {
        case NSOrderedSame:             //相等
        {
            return NSOrderedSame;
        }
            break;
        case NSOrderedAscending:        //date1比date2小
        {
            return NSOrderedAscending;
        }
            break;
        case NSOrderedDescending:       //date1比date2大
        {
            return NSOrderedDescending;
        }
            break;
            
        default:
            
            NSLog(@"非法时间");
            
            break;
    }
    
    return NSOrderedSame;
}

//计算两个时间的时间差NSDate
+(double)timeDiffWithDate:(NSDate *)date1 date2:(NSDate *)date2
{
    double timeDiff = 0.0;
    
    timeDiff = [date2 timeIntervalSinceDate:date1];
    
    return timeDiff;
    
}

//计算两个时间的时间差String
+(double)timeDiffWithTimeString:(NSString *)time1 time2:(NSString *)time2 formatter:(NSString *)formatter
{
    double timeDiff = 0.0;
    
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:formatter];
    NSDate *date1 = [formatter1 dateFromString:time1];
    
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    [formatter2 setDateFormat:formatter];
    NSDate *date2 = [formatter2 dateFromString:time2];
    
    timeDiff = [self timeDiffWithDate:date1 date2:date2];
    
    return timeDiff;
    
}

#pragma mark - Image处理

/*  UIButton 图片背景不拉伸
 *
 *  top顶部高度
 *  bottom底部高度
 *  left左部宽度
 *  right右部宽度
 */
+(UIImage *)noStretchImageWithImage:(UIImage *)image
                                Top:(CGFloat)top
                             Bottom:(CGFloat)bottom
                               Left:(CGFloat)left
                              Right:(CGFloat)right
{
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    
    if (IOS_VERSION>=6.0) {
        image = [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeTile];
    }else{
        image = [image resizableImageWithCapInsets:insets];
    }
    
    
    return image;
}

+(UIImage *)noStretchImageWithImage:(UIImage *)image
{
    UIEdgeInsets insets = UIEdgeInsetsMake(5, 5, 5, 5);
    
    if (IOS_VERSION>=6.0) {
        image = [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeTile];
    }else{
        image = [image resizableImageWithCapInsets:insets];
    }
    
    
    return image;
}

+(BOOL)imageHasAlpha: (UIImage *) image
{
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(image.CGImage);
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}
+(NSString *)image2DataURL: (UIImage *) image
{
    NSData *imageData = nil;
    NSString *mimeType = nil;
    
    if ([self imageHasAlpha: image]) {
        imageData = UIImagePNGRepresentation(image);
        mimeType = @"image/png";
    } else {
        imageData = UIImageJPEGRepresentation(image, 1.0f);
        mimeType = @"image/jpeg";
    }
    
    return [imageData base64EncodedStringWithOptions: 0];
}

//将图片转为base64
+(NSString *)base64StringFromImage:(UIImage *)image
{
    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
    
    return [data base64EncodedString];
}
+(float) widthForString:(NSString *)value fontSize:(float)fontSize andHeight:(float)height
{
   // CGSize sizeToFit = [value sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(CGFLOAT_MAX, height) lineBreakMode:NSLineBreakByWordWrapping];//此处的换行类型（lineBreakMode）可根据自己的实际情况进行设置
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]};
    
    CGRect rect = [value boundingRectWithSize:CGSizeMake(UISCREENWITH, height) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attributes context:nil];
    return rect.size.width;
}
//获得字符串的高度
+(float) heightForString:(NSString *)value fontSize:(float)fontSize andWidth:(float)width
{
     CGRect rect = [value boundingRectWithSize:CGSizeMake(width, 0) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil];
    
    //CGSize sizeToFit = [value sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByCharWrapping];//此处的换行类型（lineBreakMode）可根据自己的实际情况进行设置
    return rect.size.height;
}
#pragma mark - UDID

+(NSString *)getUDID
{
    NSString *udid = [[NSUserDefaults standardUserDefaults] objectForKey:@"udid"];
    
    if (!udid || [udid isEqualToString:@""]) {
        
        udid = [NSString stringWithFormat:@"%@",[SvUDIDTools UDID]];
        
        udid = [udid stringByReplacingOccurrencesOfString:@"-" withString:@""];
        
    }
    
    //保存udid
    [[NSUserDefaults standardUserDefaults] setObject:udid forKey:@"udid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return udid;
}

#pragma mark - 设备相关
//设备型号
+ (NSString*)deviceVersion
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString * deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    //iPhone
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
        
    return deviceString;
}
//操作系统
+(NSString *)getSystemName
{
    return [UIDevice currentDevice].systemName;
}

//操作系统版本
+(NSString *)getSystemVersion
{
    return [UIDevice currentDevice].systemVersion;
}

+ (NSString*)getDeviceVersion
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char*)malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

//设备型号
+ (NSString *)getDeviceModel
{
    NSString *platform = [self getDeviceVersion];
    //iPhone
    if ([platform isEqualToString:@"iPhone1,1"])   return@"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])   return@"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])   return@"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])   return@"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"])   return@"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])   return@"iPhone 4 (CDMA)";
    if ([platform isEqualToString:@"iPhone4,1"])   return @"iPhone 4s";
    if ([platform isEqualToString:@"iPhone5,1"])   return @"iPhone 5 (GSM/WCDMA)";
    if ([platform isEqualToString:@"iPhone4,2"])   return @"iPhone 5 (CDMA)";
    
    //iPot Touch
    if ([platform isEqualToString:@"iPod1,1"])     return@"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])     return@"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])     return@"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])     return@"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])     return@"iPod Touch 5G";
    //iPad
    if ([platform isEqualToString:@"iPad1,1"])     return@"iPad";
    if ([platform isEqualToString:@"iPad2,1"])     return@"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])     return@"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])     return@"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])     return@"iPad 2 New";
    if ([platform isEqualToString:@"iPad2,5"])     return@"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad3,1"])     return@"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])     return@"iPad 3 (CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])     return@"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])     return@"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"i386"] || [platform isEqualToString:@"x86_64"])        return@"Simulator";
    
    return platform;
}

+(UIFont *)getLightFontSize:(NSInteger)size{
    
    if (iPhone6)
        return kLightTextFont(size+1);
    else if ( iPhone6Plus)
        return kLightTextFont(size+2);
    else
        return kLightTextFont(size);
}
+(UIFont *)getBlodFontSize:(NSInteger)size{
    if (iPhone6)
        return kBoldTextFont(size+1);
    else if ( iPhone6Plus)
        return kBoldTextFont(size+2);
    else
        return kLightTextFont(size);
}

+(UIViewController*) findBestViewController:(UIViewController*)vc {
    
    if (vc.presentedViewController) {
        
        // Return presented view controller
        return [ToolUtils findBestViewController:vc.presentedViewController];
        
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        
        // Return right hand side
        UISplitViewController* svc = (UISplitViewController*) vc;
        if (svc.viewControllers.count > 0)
            return [ToolUtils findBestViewController:svc.viewControllers.lastObject];
        else
            return vc;
        
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        
        // Return top view
        UINavigationController* svc = (UINavigationController*) vc;
        if (svc.viewControllers.count > 0)
            return [ToolUtils findBestViewController:svc.topViewController];
        else
            return vc;
        
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        
        // Return visible view
        UITabBarController* svc = (UITabBarController*) vc;
        if (svc.viewControllers.count > 0)
            return [ToolUtils findBestViewController:svc.selectedViewController];
        else
            return vc;
        
    } else {
        
        // Unknown view controller type, return last child view controller
        return vc;
        
    }
    
}

+(UIViewController*) currentViewController {
    
    // Find best view controller
    UIViewController* viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [ToolUtils findBestViewController:viewController];
    
}
//经度
+ (NSNumber *)latitude
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"latitude"];
}
//纬度
+ (NSNumber *)longitude
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"longitude"];
}
+ (NSString *)country
{
    NSLocale *locale = [NSLocale currentLocale];
    NSString *country = [locale localeIdentifier];
    return country;
}
+ (NSString *)language
{
    NSArray *languageArray = [NSLocale preferredLanguages];
    NSString *language = [languageArray objectAtIndex:0];
    return language;
}
+ (NSString *)timeZone
{
    return  [NSTimeZone systemTimeZone].name;
}
+ (NSString *)CFNetType
{
    NSString *strNetworkType = @"";
    
    //创建零地址，0.0.0.0的地址表示查询本机的网络连接状态
    struct sockaddr_storage zeroAddress;
    
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.ss_len = sizeof(zeroAddress);
    zeroAddress.ss_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    //获得连接的标志
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    //如果不能获取连接标志，则不能连接网络，直接返回
    if (!didRetrieveFlags)
    {
        return strNetworkType;
    }
    
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
    {
        // if target host is reachable and no connection is required
        // then we'll assume (for now) that your on Wi-Fi
        strNetworkType = @"WIFI";
    }
    
    if (
        ((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
        (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0
        )
    {
        // ... and the connection is on-demand (or on-traffic) if the
        // calling application is using the CFSocketStream or higher APIs
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            // ... and no [user] intervention is needed
            strNetworkType = @"WIFI";
        }
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
    {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        {
            CTTelephonyNetworkInfo * info = [[CTTelephonyNetworkInfo alloc] init];
            NSString *currentRadioAccessTechnology = info.currentRadioAccessTechnology;
            
            if (currentRadioAccessTechnology)
            {
                if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE])
                {
                    strNetworkType =  @"4G";
                }
                else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS])
                {
                    strNetworkType =  @"2G";
                }
                else
                {
                    strNetworkType =  @"3G";
                }
            }
        }
        else
        {
            if((flags & kSCNetworkReachabilityFlagsReachable) == kSCNetworkReachabilityFlagsReachable)
            {
                if ((flags & kSCNetworkReachabilityFlagsTransientConnection) == kSCNetworkReachabilityFlagsTransientConnection)
                {
                    if((flags & kSCNetworkReachabilityFlagsConnectionRequired) == kSCNetworkReachabilityFlagsConnectionRequired)
                    {
                        strNetworkType = @"2G";
                    }
                    else
                    {
                        strNetworkType = @"3G";
                    }
                }
            }
        }
    }
    
    
    if ([strNetworkType isEqualToString:@""]) {
        strNetworkType = @"WWAN";
    }
    
    //NSLog( @"GetNetWorkType() strNetworkType :  %s", strNetworkType.c_str());
    
    return strNetworkType;
}
+ (NSString *)getIPAddress {
    
    NSString *address = @"127.0.0.1";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}

// 根据图片字节长度，获得压缩因子
+ (float)imageGetScaleFactor:(int) bytesSize {
    if (bytesSize < 100*1024) { // 小于100k,按照原始比例的1/2压缩
        return 0.5;
    } else if(bytesSize >= 100*1024 && bytesSize < 500*1024){ // 100k =< bytesSize < 500k
        return 0.4;
    } else if(bytesSize >= 500*1024 && bytesSize < 1000*1024){ // 500k =< bytesSize < 1M
        return 0.3;
    } else if (bytesSize >= 1000*1024 && bytesSize < 5000*1024) { // 1000k =< bytesSize < 5M
        return 0.2;
    } else { // 大于5M
        return 0.1;
    }
}
+ (BOOL)ckeckNetWoring
{
    
    Reachability *reach = [Reachability reachabilityForLocalWiFi];
    NetworkStatus status = [reach currentReachabilityStatus];
    if (status == NotReachable) {
        return NO;
    }
    else
    {
        return YES;
    }
}
+ (void)drawShadowForBottomView:(UIView *)view
{
    view.layer.shadowColor = [ToolUtils colorWithHexString:@"626262"].CGColor;
    view.layer.shadowOffset = CGSizeMake(0, -1.0f);
    view.layer.shadowOpacity = 0.3f;
    view.clipsToBounds = NO;
}



// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to mlamb.
//
+ (NSString *) macaddress
{
    int                    mib[6];
    size_t                len;
    char                *buf;
    unsigned char        *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl    *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1/n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    // NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    NSString *outstring = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    return [outstring uppercaseString];
}
//判断输入的内容是全否为数字
+ (BOOL)deptNumInputShouldNumber:(NSString *)str
{
    NSString *regex = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:str]) {
        return YES;
    }
    return NO;
}
@end
