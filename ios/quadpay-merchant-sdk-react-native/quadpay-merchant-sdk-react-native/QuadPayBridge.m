
#import "QuadPayBridge.h"
#import <QuadPaySDK/QuadPaySDK.h>
#import <React/RCTUtils.h>

@interface QuadPayBridge () <RCTBridgeModule, QuadPayVirtualCheckoutDelegate, QuadPayCheckoutDelegate>

@end

@implementation QuadPayBridge
RCT_EXPORT_MODULE();

bool hasListeners;

-(void)startObserving {
    hasListeners = YES;
}
-(void)stopObserving {
    hasListeners = NO;
}

- (NSArray<NSString *> *)supportedEvents {
    return @[
      @"checkoutCancelled",
      @"checkoutError",
      @"checkoutSuccessful"
    ];
}

- (void)didFailWithError:(QuadPayVirtualCheckoutViewController*)viewController error:(nonnull NSString *)error {
  [viewController dismissViewControllerAnimated:true completion:^ {
    if (hasListeners) {
      [self sendEventWithName:@"checkoutError" body:@{@"error": [error length] >0 ? error : @""}];
    }
  }];
}

- (void)checkoutCancelled:(QuadPayVirtualCheckoutViewController*)viewController reason:(NSString *)reason {
    [viewController dismissViewControllerAnimated:true completion:^ {
      if (hasListeners) {
        [self sendEventWithName:@"checkoutCancelled" body:@{@"reason": [reason length] >0 ? reason : @""}];
      }
    }];
}

- (void)checkoutSuccessful:(nonnull QuadPayCheckoutViewController *)viewController orderId:(nonnull NSString *)orderId {
  [viewController dismissViewControllerAnimated:true completion:^ {
    if (hasListeners) {
      [self sendEventWithName:@"checkoutSuccessful" body:@{ @"orderId": orderId}];
    }
  }];
}


- (void) checkoutSuccessful:(QuadPayVirtualCheckoutViewController*)viewController card:(nonnull QuadPayCard *)card cardholder:(nonnull QuadPayCardholder *)cardholder {
    [viewController dismissViewControllerAnimated:true completion:^ {
      if (hasListeners) {
        NSDictionary *body = @{
          @"card": @{
              @"brand": card.brand,
              @"cvc": card.cvc,
              @"expirationMonth": card.expirationMonth,
              @"expirationYear": card.expirationYear,
              @"number": card.number
          },
          @"cardholder": @{
              @"addressLine1": cardholder.addressLine1,
              @"addressLine2": cardholder.addressLine2,
              @"city": cardholder.city,
              @"name": cardholder.name,
              @"postalCode": cardholder.postalCode,
              @"state": cardholder.state
          }
        };
        [self sendEventWithName:@"checkoutSuccessful" body:body];
      }
    }];
}

RCT_EXPORT_METHOD(initialize:(NSString*) key environment:(NSString*)environment locale:(NSString*) locale) {
  [[QuadPay sharedInstance] initialize:key environment:environment locale:locale];
}

RCT_EXPORT_METHOD(startVirtualCheckout:
                  (NSString*) amount
                  merchantReference:(NSString*) merchantReference
                  customerFirstName:(NSString*) customerFirstName
                  customerEmail:(NSString*) customerEmail
                  customerLastName:(NSString*) customerLastName
                  customerPhoneNumber:(NSString*) customerPhoneNumber
                  customerAddressLine1:(NSString*) customerAddressLine1
                  customerAddressLine2:(NSString*) customerAddressLine2
                  customerPostalCode:(NSString*) customerPostalCode
                  customerCity:(NSString*) customerCity
                  customerState:(NSString*) customerState
                  customerCountry:(NSString*) customerCountry
    ) {
    dispatch_async(dispatch_get_main_queue(), ^{
      QuadPayCheckoutDetails* details = [QuadPayCheckoutDetails alloc];
        details.amount = [NSDecimalNumber decimalNumberWithString:amount locale:NULL];
        details.merchantReference = merchantReference;
        details.customerPhoneNumber = customerPhoneNumber;
        details.customerCity = customerCity;
        details.customerState = customerState;
        details.customerAddressLine1 = customerAddressLine1;
        details.customerAddressLine2 = customerAddressLine2;
        details.customerPostalCode = customerPostalCode;
        details.customerCountry = customerCountry;
        details.customerFirstName = customerFirstName;
        details.customerLastName = customerLastName;
        details.customerEmail = customerEmail;

      QuadPayVirtualCheckoutViewController* view = [QuadPayVirtualCheckoutViewController startCheckout:self details:details];
          UIViewController *rootViewController = RCTPresentedViewController();
      
          [rootViewController presentViewController:view animated:YES completion:nil];
    });
}

RCT_EXPORT_METHOD(startCheckout:
                  (NSString*) amount
                  merchantReference:(NSString*) merchantReference
                  customerFirstName:(NSString*) customerFirstName
                  customerEmail:(NSString*) customerEmail
                  customerLastName:(NSString*) customerLastName
                  customerPhoneNumber:(NSString*) customerPhoneNumber
                  customerAddressLine1:(NSString*) customerAddressLine1
                  customerAddressLine2:(NSString*) customerAddressLine2
                  customerPostalCode:(NSString*) customerPostalCode
                  customerCity:(NSString*) customerCity
                  customerState:(NSString*) customerState
                  customerCountry:(NSString*) customerCountry
    ) {
    dispatch_async(dispatch_get_main_queue(), ^{
      QuadPayCheckoutDetails* details = [QuadPayCheckoutDetails alloc];
          details.amount = [NSDecimalNumber decimalNumberWithString:amount locale:NULL];
          details.merchantReference = merchantReference;
          details.customerPhoneNumber = customerPhoneNumber;
          details.customerCity = customerCity;
          details.customerState = customerState;
          details.customerAddressLine1 = customerAddressLine1;
          details.customerAddressLine2 = customerAddressLine2;
          details.customerPostalCode = customerPostalCode;
          details.customerCountry = customerCountry;
          details.customerFirstName = customerFirstName;
          details.customerLastName = customerLastName;
          details.customerEmail = customerEmail;

      QuadPayCheckoutViewController* view = [QuadPayCheckoutViewController startCheckout:self details:details];
          UIViewController *rootViewController = RCTPresentedViewController();
      
          [rootViewController presentViewController:view animated:YES completion:nil];
    });
}

@end