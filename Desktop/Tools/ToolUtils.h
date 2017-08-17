//
//  ToolUtils.h
//  拍卖行
//
//  Created by admin on 13-8-29.
//  Copyright (c) 2013年 liouly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface ToolUtils : NSObject

//返回Cache路径
+(NSString *)returnCachePath;

//返回首字母数组
+(NSMutableArray *)chineseSourtOutToFirstLetter:(NSMutableArray *)array;

//按照key对数组进行排序
+(NSMutableArray *)sortWithDescriptor:(NSMutableArray *)arrayToSort Key:(NSString *)key;

//获得Label的高度
+(CGFloat)heightForLabel:(UILabel *)contentLab;

//获得Label的宽度
+(CGFloat)widthForLabel:(UILabel *)contentLab;

//获得TextView的高度
+(CGFloat)heightForTextView:(UITextView *)textView;
//获取字符串宽度
+(float) widthForString:(NSString *)value fontSize:(float)fontSize andHeight:(float)height;
//获得字符串的高度
+(float) heightForString:(NSString *)value fontSize:(float)fontSize andWidth:(float)width;

//保存数据到本地沙盒
+(void)setDataToSandboxWithPersonalInfo:(NSDictionary *)dicToSandbox;

//读取沙盒中的数据
+(NSDictionary *)getDataFromSanboxWithPersonalInfo;

//删除沙盒中的数据
+(void)deleteDataInSanbox;

//判断沙盒中是否有数据
+(BOOL)isDataInSanbox;

//计算指定文件夹下的文件总大小
+(float)folderSizeAtPath:(NSString*) folderPath;

//删除Document文件夹下的图片
+ (void)deletePicAtDoc;

+ (float)documentFolderSize;

//计算指定文件的大小
+(float)fileSizeAtPath:(NSString*) filePath;

//删除指定文件夹下的文件
+(void)removeFolderWithPath:(NSString *)folderPath;

//删除本地的指定文件
+(void)deleteFileWithFileName:(NSString *)fileName;

//检测邮箱是否正确
+ (BOOL)checkEmail:(NSString *)str;

//加载提示框
+ (void)showHUD:(NSString *)text andView:(UIView *)view andHUD:(MBProgressHUD *)hud;
//提示框
+ (void)showCustomViewHUD:(NSString *)text imageName:(NSString *)image andViewController:(UIViewController *)view;
//
//提示框
+ (void)showCustomViewHUD:(NSString *)text imageName:(NSString *)image andView:(UIView *)view;
+ (NSString *)md5:(NSString *)str;

+(BOOL)checkUrl:(NSString *)url;



+ (BOOL)checkPrice:(NSString *)str;

+ (BOOL)ckeckNetWoring;

//16进制颜色获取
+ (UIColor *) colorWithHexString: (NSString *)color;
+ (UIColor *) colorWithHexString: (NSString *)color andAlpha:(CGFloat )alpha;

//返回完整的图片路径
+(NSString *)orgianPath:(NSString *)imagePath;

+(BOOL)isEmpty:(NSString *)string;

#pragma mark - 日期

//返回格式化时间String
+(NSString *)dateStringFromDate:(NSDate *)date Formatter:(NSString *)formatterString;

//返回当前时间Date
+(NSDate *)getCurrentDateWithFormatter:(NSString *)formatterString;

//NSString 转 Date
+(NSDate *)dateFromDateString:(NSString *)dateString Formatter:(NSString *)matter;

//转为北京时间
+ (NSDate *)dateForGMT:(NSDate *)data;

//返回当前时间
+(NSString *)getTimeNowWithFormatter:(NSString *)formatterString;

//时间比较
+(NSComparisonResult)checkDateTimeWithDate1:(NSDate *)date1 Data2:(NSDate *)date2;

//计算两个时间的时间差NSDate
+(double)timeDiffWithDate:(NSDate *)date1 date2:(NSDate *)date2;

//计算两个时间的时间差String
+(double)timeDiffWithTimeString:(NSString *)time1 time2:(NSString *)time2 formatter:(NSString *)formatter;

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
                              Right:(CGFloat)right;

+(UIImage *)noStretchImageWithImage:(UIImage *)image;

//将图片转为base64
+(NSString *)image2DataURL: (UIImage *) image;
+(NSString *)base64StringFromImage:(UIImage *)image;

#pragma mark - UDID
//设备型号
+ (NSString*)deviceVersion;

+(NSString *)getUDID;

//操作系统
+(NSString *)getSystemName;

//设备型号
+(NSString *)getDeviceModel;

//操作系统版本
+ (NSString *)getSystemVersion;
//mac地址
+ (NSString *) macaddress;
//获取IP地址
+ (NSString *)getIPAddress ;
//网络类型
+ (NSString *)CFNetType;
//当前获取时区
+ (NSString *)timeZone;
//当前语言
+ (NSString *)language;
//获取当前国家
+ (NSString *)country;
//经度
+ (NSNumber *)latitude;
//纬度
+ (NSNumber *)longitude;
+(UIFont *)getLightFontSize:(NSInteger)size;
+(UIFont *)getBlodFontSize:(NSInteger)size;


+(UIViewController*) currentViewController;


+ (float)imageGetScaleFactor:(int) bytesSize ;

+ (void)drawShadowForBottomView:(UIView *)view;
//验证身份证号

+ (BOOL)accurateVerifyIDCardNumber:(NSString *)value;
//验证手机号

+(BOOL)checkPhone:(NSString*)checkString;
//判断输入的内容是全否为数字
+ (BOOL)deptNumInputShouldNumber:(NSString *)str;
@end
