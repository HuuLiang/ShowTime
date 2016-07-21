//
//  STConfig.h
//  ShowTime
//
//  Created by Sean Yue on 16/1/26.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#ifndef STConfig_h
#define STConfig_h

#import "STConfiguration.h"

#define ST_CHANNEL_NO           [STConfiguration sharedConfig].channelNo
#define ST_PACKAGE_CERTIFICATE  @"iPhone Distribution: Neijiang Fenghuang Enterprise (Group) Co., Ltd."

#define ST_REST_APP_ID          @"QUBA_2005"
#define ST_REST_PV              @110
#define ST_PAYMENT_PV           @100
#define ST_REST_APP_VERSION     ((NSString *)([NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"]))

//#define ST_BASE_URL             @"http://120.24.252.114:8093"
#define ST_BASE_URL             @"http://iv.zcqcmj.com"
#define ST_STANDBY_BASE_URL     @""

#define ST_HOME_PAGE_URL            @"/iosvideo/homePage.htm"
#define ST_HOT_VIDEO_URL            @"/iosvideo/hotVideo.htm"
#define ST_USER_ACCESS_URL          @"/iosvideo/userAccess.htm"
#define ST_ACTIVATE_URL             @"/iosvideo/activat.htm"
#define ST_ALIPAY_CONFIG_URL        @"/iosvideo/aliConfig.htm"
#define ST_WECHATPAY_CONFIG_URL     @"/iosvideo/weixinConfig.htm"
#define ST_SYSTEM_CONFIG_URL        @"/iosvideo/systemConfig.htm"
#define ST_AGREEMENT_NOTPAID_URL    @"/iosvideo/show-agreement.html"
#define ST_COMMENT_URL              @"/iosvideo/comment.htm"
#define ST_AGREEMENT_PAID_URL       @"/iosvideo/show-agreement-paid.html"
#define ST_Q_AND_A_URL              @"/iosvideo/q-a.html"

#define ST_PAYMENT_COMMIT_URL            @"http://pay.zcqcmj.com/paycenter/qubaPr.json"//@"http://120.24.252.114:8084/paycenter/qubaPr.json"//
#define ST_PAYMENT_CONFIG_URL            @"http://pay.zcqcmj.com/paycenter/payConfig.json"//@"http://120.24.252.114:8084/paycenter/payConfig.json"//
#define ST_STANDBY_PAYMENT_CONFIG_URL    @"http://appcdn.mqu8.com/static/iosvideo/payConfig_%@.json"
#define ST_PAYMENT_RESERVE_DATA         [NSString stringWithFormat:@"%@$%@", ST_REST_APP_ID, ST_CHANNEL_NO]


#define ST_STATS_BASE_URL              @"http://stats.iqu8.cn"//@"http://120.24.252.114"//
#define ST_STATS_CPC_URL               @"/stats/cpcs.service"
#define ST_STATS_TAB_URL               @"/stats/tabStat.service"
#define ST_STATS_PAY_URL               @"/stats/payRes.service"
static NSString *const kLaunchSeqKeyName = @"stshoutime_launchseq_keyname";



#define ST_WECHAT_APP_ID        @"wx4af04eb5b3dbfb56"
#define ST_WECHAT_MCH_ID        @"1281148901"
#define ST_WECHAT_PRIVATE_KEY   @"hangzhouquba20151112qwertyuiopas"
#define ST_WECHAT_NOTIFY_URL    @"http://phas.ihuiyx.com/pd-has/notifyWx.json"

#define ST_ALIPAY_PARTNER       @"2088121441452190"
#define ST_ALIPAY_SELLER        @"344369174@qq.com"
#define ST_ALIPAY_NOTIFY_URL    @"http://phas.ihuiyx.com/pd-has/notifyByAlipay.json"
#define ST_ALIPAY_PRODUCT_INFO  @"直播秀"
#define ST_ALIPAY_PRIVATE_KEY   @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAM2bjQaX3KpJOrEuiDooHl4weqQlobMHbDZji6kX2UZHOnl9dIUMZu3m1EJLjNHGNREK8YeNMamVBfq2hkSzJRWcYdplMC74dK3VTdZoMKsU73fn5ThCetqFTtAOLrTWbhC3rDG1yratEWExKK+vfl6kKDHtIvJleB552bWDsTXdAgMBAAECgYEAgGPN4HwcE0m/GL0R3B8JN4/WRYIqQv0zmZL3txNpXfVEknDAvgRMkeo+SVecC7JVmNrYj+ifRmIEZdZsaaHkWUeGxUJP0pmhFHr5fBTAynkSX6ycQAluTCsyrQHe/6ezhenAeXh4Wnl7ey4cwvLq4L2KlhuzBg2k12N3tdF3tJECQQDwGM7TC5/5XYWBaQ1M3BnZ+Uik7ZC5B3UxxnWimESNG3tyUAKn22rfNkJ+FuHq1svP28pf+VwSZ5AF8wGDN2/vAkEA2zntUAC/FGLcYrgtYYL2gfgBrYlae9L+rT5jDKd4E44zTUbx63fSnHNGRjloLk+fln+ToDjdW5Q9oTi+ANdq8wJATbFJZAOT/aZkqC6tThy/BMjk1/HD7gvawYOd10J8lEi7Vo9LfLPEznwJYjHXYx2kkBtoTkwrng0DDtnGuIY84wJAAvXcS4lHC0pueXLNQhTXqVelBiflrehiggpmogQc7f6smK2NlMVwdaZk24vo6T8wA4NDhhVef98Xmfa/Mhm2mwJAWqQA9Pc+rKhW829K5deWOFs1YC9ME+M6hZmnTaa0XdupiV0Y4p0ywkH2topfwR8tEQdbXmzKU+oCR5XadwOlrw=="
#define ST_ALIPAY_SCHEME        @"comshowtimevappalipayurlscheme"

#define ST_UMENG_APP_ID         @"56a8cab7e0f55ab987001edb"

#define ST_SYSTEM_CONFIG_PAY_AMOUNT         @"PAY_AMOUNT"
#define ST_SYSTEM_CONFIG_PAY_IMG            @"PAY_IMG"
#define ST_SYSTEM_CONFIG_CHANNEL_TOP_IMAGE  @"CHANNEL_TOP_IMG"
#define ST_SYSTEM_CONFIG_STARTUP_INSTALL    @"START_INSTALL"
#define ST_SYSTEM_CONFIG_SPREAD_TOP_IMAGE   @"SPREAD_TOP_IMG"
#define ST_SYSTEM_CONFIG_SPREAD_URL         @"SPREAD_URL"
#define ST_SYSTEM_CONFIG_STATS_TIME_INTERVAL   @"STATS_TIME_INTERVAL"
#define ST_SYSTEM_CONFIG_CONTACT               @"CONTACT"




#endif /* STConfig_h */
