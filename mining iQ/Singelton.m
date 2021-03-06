//
//  Singelton.m
//  testk
//
//  Created by Karmick 7 on 01/10/15.
//  Copyright (c) 2015 Karmick 7. All rights reserved.
//

#import "Singelton.h"
#import <CoreData/CoreData.h>
@implementation Singelton
@synthesize firstname,lastname,usertype,userid,email,phone,profileimgUrl,strAddress;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

 static Singelton* sharedInstance = nil;

+(Singelton *)getInstance {
    @synchronized(self)
    {
        if (sharedInstance == nil)
        sharedInstance = [[self alloc] init];
            }
    return(sharedInstance);
}

- (id)init
{
    self = [super init];
    if ( self )
    {

        
    }
    return self;
}

- (NSManagedObjectContext *)managedObjectContext {
    
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
    
}

-(NSString *)demoMethod:(NSString*)outputString{

    NSString *splitstring;
    splitstring = outputString;
    NSArray *listItems = [splitstring componentsSeparatedByString:@","];
    
    return [NSString stringWithFormat:@"%@",[listItems objectAtIndex:0]];
}

-(NSMutableArray *)dataFromCoredata:(NSString *)entityName{
    
    NSMutableArray *setVal = [[NSMutableArray alloc] init];
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entityName];
    setVal = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    return setVal;
}

-(void)jsonparse:(void(^)(NSDictionary* result))handler andString:(NSString*) yourString{
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:yourString]];
    
    NSString *authStr = @"";
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat: @"Basic %@",[authData base64EncodedStringWithOptions:0]];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    //create the task
    NSURLSessionDataTask* task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error == nil)
        {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(json) ;
                
            });
        }
        
    }];
    [task resume];
    
}

-(void)jsonParseWithPostMethod:(void(^)(NSDictionary* result))handler andString:(NSString*) yourString andParam:(NSString *)param{
    
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSURL * url = [NSURL URLWithString:yourString];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString * params =param;
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                           NSLog(@"Response:%@ %@\n", response, error);
                                                           if(error == nil)
                                                           {
                                                               NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                               
                                                               NSLog(@"*****%@",newStr);
                                                               
                                                               
                                                               NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                               
                                                              
                                                               
                                                               
                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                   handler(json) ;
                                                                   
                                                               });
                                                               
                                                           }
                                                           
                                                       }];
    [dataTask resume];
}

-(void)ButtonEdgeChange:(UIButton *)button spacing:(float)space{
    
    // the space between the image and text
    CGFloat spacing = space;
    
    // lower the text and push it left so it appears centered
    //  below the image
    CGSize imageSize = button.imageView.image.size;
    button.titleEdgeInsets = UIEdgeInsetsMake(
                                              0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    
    // raise the image and push it right so it appears centered
    //  above the text
    CGSize titleSize = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: button.titleLabel.font}];
    button.imageEdgeInsets = UIEdgeInsetsMake(
                                              - (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);


}

-(void)saveDefaults:(NSDictionary *)result{

   
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:[result objectForKey:@"user_id"] forKey:@"user_id"];
    [defaults setObject:[result objectForKey:@"first_name"] forKey:@"first_name"];
    [defaults setObject:[result objectForKey:@"email_id"] forKey:@"email_id"];
    [defaults setObject:[result objectForKey:@"phone"] forKey:@"phone"];
    [defaults setObject:[result objectForKey:@"profile_image"] forKey:@"profile_image"];
    [defaults setObject:[result objectForKey:@"address"] forKey:@"Address"];
    [defaults setObject:@"yes" forKey:@"isLogin"];
    [defaults setObject:[result objectForKey:@"login_type"] forKey:@"login_type"];
    [defaults synchronize];
    
}

-(NSString *)getLoginId{
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"user_id"];

}

-(NSString *)getDeviceToken{
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"deviceToken"];
    
}

-(void)saveDefaultsGuest{
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:@"demoId" forKey:@"user_id"];
    [defaults setObject:@"demoFirstName" forKey:@"first_name"];
    [defaults setObject:@"demoLastName" forKey:@"last_name"];
    [defaults setObject:@"2" forKey:@"userType"];
    [defaults synchronize];
    
}

-(BOOL)isDeviceLocalizationArabic
{
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    return [language rangeOfString:@"ar"].location != NSNotFound;
}

-(NSString *)deviceID
{
    UIDevice *device = [UIDevice currentDevice];
    NSString  *currentDeviceId = [[device identifierForVendor]UUIDString];
    return currentDeviceId;
}

-(BOOL)isNumeric:(NSString*)inputString
{
    BOOL isValid = NO;
    NSCharacterSet *alphaNumbersSet = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *stringSet = [NSCharacterSet characterSetWithCharactersInString:inputString];
    isValid = [alphaNumbersSet isSupersetOfSet:stringSet];//returns TRUE if numeric, else returns FALSE
    return isValid;
}

- (BOOL)isValidPassword:(NSString*)password
{
    return  password.length>5?TRUE:FALSE;
}

-(BOOL)IsBlank:(NSString *)str
{
    if([str isEqual:[NSNull null]])
        return TRUE;
    return ([[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])?TRUE:FALSE;
}

-(NSString *)trim:(NSString *)str
{
    NSString *trimmedString = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return trimmedString;
}

- (BOOL)validateEmailWithString:(NSString*)eMail
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:eMail];
}

@end
