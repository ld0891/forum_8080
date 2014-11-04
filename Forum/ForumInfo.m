//
//  ForumInfo.m
//  Forum
//
//  Created by DI LIU on 8/13/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import "ForumInfo.h"

@interface ForumInfo ()

@property (nonatomic) NSMutableParagraphStyle *privateStyle;
@property (nonatomic) NSArray *privateSectionNames;
@property (nonatomic) NSDictionary *sectionKeyDic;

@end

@implementation ForumInfo

+ (instancetype)sharedInfo
{
    static ForumInfo *_sharedInfo = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once( &onceToken, ^{
        _sharedInfo = [[self alloc] init];
    });
    
    return _sharedInfo;
}

- (instancetype)init
{
    self = [super init];
    if ( self ) {
        _baseURL = @"http://bbs.8080.net/";
        _loginURL = @"member.php";
        _codeURL = @"misc.php";
        _replyURL = @"forum.php";
        
        _privateSectionNames = @[ @"微软同盟",
                          @"安卓乐园",
                          @"苹果之家",
                          @"色友俱乐部",
                          @"宽带3G",
                          @"硬件高手",
                          @"我爱我家",
                          @"投资理财",
                          @"影音人生",
                          @"游戏世界",
                          @"强身健体",
                          @"极速汽车",
                          @"美食旅游",
                          @"古城大爱",
                          @"亲亲宝贝",
                          @"点滴生活",
                          @"电脑散件",
                          @"配件外设",
                          @"整机风云",
                          @"时尚本本",
                          @"潮流数码",
                          @"移动天下",
                          @"服饰鞋帽",
                          @"汽车服务",
                          @"吃货天堂",
                          @"跳蚤市场",
                          @"海淘代购",
                          @"人才招聘",
                          @"杂货物品",
                          @"旺铺租赁",
                          @"家政服务",
                          @"站务&招商" ];
        
        _sectionKeyDic = @{ @"微软同盟": @"SettingsShowMicrosoftAlliance",
                            @"安卓乐园": @"SettingsShowAndroidJoypark",
                            @"苹果之家": @"SettingsShowAppleHome",
                            @"色友俱乐部": @"SettingsShowPhotographerClub",
                            @"宽带3G": @"SettingsShowBroadband3G",
                            @"硬件高手": @"SettingsShowHardwareExpert",
                            @"我爱我家": @"SettingsShowILoveMyHome",
                            @"投资理财": @"SettingsShowInvestment",
                            @"影音人生": @"SettingsShowAVLife",
                            @"游戏世界": @"SettingsShowGameWorld",
                            @"强身健体": @"SettingsShowPhysicalTraining",
                            @"极速汽车": @"SettingsShowSpeedAuto",
                            @"美食旅游": @"SettingsShowFoodTour",
                            @"古城大爱": @"SettingsShowCharity",
                            @"亲亲宝贝": @"SettingsShowDearBaby",
                            @"点滴生活": @"SettingsShowDailyLife",
                            @"电脑散件": @"SettingsShowComputerHardware",
                            @"配件外设": @"SettingsShowAccessoryPeripheral",
                            @"整机风云": @"SettingsShowDesktop",
                            @"时尚本本": @"SettingsShowLaptop",
                            @"潮流数码": @"SettingsShowTrendyGadget",
                            @"移动天下": @"SettingsShowMobileWorld",
                            @"服饰鞋帽": @"SettingsShowClothing",
                            @"汽车服务": @"SettingsShowAutoService",
                            @"吃货天堂": @"SettingsShowGourmetHeaven",
                            @"跳蚤市场": @"SettingsShowFleaMarket",
                            @"海淘代购": @"SettingsShowGlobalShopping",
                            @"人才招聘": @"SettingsShowEmployment",
                            @"杂货物品": @"SettingsShowMiscGood",
                            @"旺铺租赁": @"SettingsShowShopForRent",
                            @"家政服务": @"SettingsShowHomeService",
                            @"站务&招商": @"SettingsShowForumAffair" };
        
        [self initSectionNames];
        
        _sectionDic = @{ @"微软同盟": @101,
                         @"安卓乐园": @91,
                         @"苹果之家": @95,
                         @"色友俱乐部": @96,
                         @"宽带3G": @97,
                         @"硬件高手": @78,
                         @"我爱我家": @81,
                         @"投资理财": @85,
                         @"影音人生": @83,
                         @"游戏世界": @84,
                         @"强身健体": @82,
                         @"极速汽车": @98,
                         @"美食旅游": @86,
                         @"古城大爱": @100,
                         @"亲亲宝贝": @87,
                         @"点滴生活": @88,
                         @"电脑散件": @120,
                         @"配件外设": @122,
                         @"整机风云": @123,
                         @"时尚本本": @124,
                         @"潮流数码": @125,
                         @"移动天下": @128,
                         @"服饰鞋帽": @130,
                         @"汽车服务": @143,
                         @"吃货天堂": @131,
                         @"跳蚤市场": @133,
                         @"海淘代购": @134,
                         @"人才招聘": @127,
                         @"杂货物品": @135,
                         @"旺铺租赁": @144,
                         @"家政服务": @146,
                         @"站务&招商": @90 };
        
        _bgColor = [UIColor colorWithRed: 233.0/256
                                   green: 231.0/256
                                    blue: 228.0/256
                                   alpha: 1.0];
        
        _darkBgColor = [UIColor colorWithRed: 73.0/256
                                       green: 73.0/256
                                        blue: 70.0/256
                                       alpha: 1.0];

        _navBgColor = [UIColor colorWithRed: 222.0/256
                                      green: 221.0/256
                                       blue: 217.0/256
                                      alpha: 1.0 ];
        
        _textColor = [UIColor colorWithRed: 33.0/256
                                     green: 33.0/256
                                      blue: 33.0/256
                                     alpha: 1.0];
        
        _lightTextColor = [UIColor colorWithRed: 220.0/256
                                          green: 220.0/256
                                           blue: 218.0/256
                                          alpha: 1.0];
        
        _buttonColor = [UIColor colorWithRed: 66.0/256
                                       green: 66.0/256
                                        blue: 66.0/256
                                       alpha: 1.0];
        
        _detailBgColor = [UIColor colorWithRed: 236.0/256
                                         green: 238.0/256
                                          blue: 235.0/256
                                         alpha: 1.0];
        
        self.privateStyle = [[NSMutableParagraphStyle alloc] init];
        [self.privateStyle setLineSpacing: 3];
        
        _loginWidth = 140.0;
        _sectionWidth = 110.0;
        _overdrawWidth = 20.0;
        
        _listHasNextPage = NO;
        _detailHasNextPage = NO;
        _isFirstLoad = YES;
    }
    
    return self;
}

- (void)initSectionNames
{
    NSMutableArray *sectionNames = [[NSMutableArray alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    for ( NSString *sectionName in _privateSectionNames) {
        NSString *sectionKey = _sectionKeyDic[sectionName];
        BOOL enabled = [defaults boolForKey: sectionKey];
        if ( enabled ) {
            [sectionNames addObject: sectionName];
        }
    }
    _sectionNames = sectionNames;
}

- (NSParagraphStyle *)style
{
    return self.privateStyle;
}

@end
