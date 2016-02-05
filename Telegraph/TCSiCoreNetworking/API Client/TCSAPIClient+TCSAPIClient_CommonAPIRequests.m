//
//  TCSAPIClient+TCSAPIClient_CommonAPIRequests.m
//  TCSiCore
//
//  Created by a.v.kiselev on 28/07/14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSAPIClient+TCSAPIClient_CommonAPIRequests.h"
#import "NSDictionary+RequestEncoding.h"
#import "UIDevice+Helpers.h"
#import "UIScreen+Helpers.h"
#import "TCSAPIStrings.h"
#import "NSError+TCSAdditions.h"
#import "TCSMacroses.h"

#import "NSDate+Calendar.h"

@implementation TCSAPIClient (TCSAPIClient_CommonAPIRequests)

#pragma mark -
#pragma mark - Session, Auth

- (void)api_getSessionIdWithUsername:(NSString *)username
							password:(NSString *)password
							deviceId:(NSString *)deviceId
							 success:(void (^)(NSString * sessionId, NSNumber *sessionTimeout))success
							 failure:(void (^)(NSError *))failure
{

	NSDictionary * params = @{
							  kUsername : username,
							  kPassword : password,
							  kDeviceId : deviceId,
							  kAppVersion : @"2.0",
							  kOrigin : @"mobile"
							  };

	MKNetworkOperation * networkOperation = [self.engine operationWithPath:TCSAPIPath_mobile_session
															  params:params
														  httpMethod:@"GET"];
	[networkOperation addCompletionHandler:^(MKNetworkOperation *completedOperation)
	 {
		 DLog(@"%@", completedOperation);
		 id responseObject = completedOperation.responseJSON;

		 if ([[responseObject objectForKey:kResultCode]isEqualToString:kResultCode_OK])
		 {
			 __block NSString * sessionId = nil;

			 [[responseObject objectForKey:TCSAPIKey_payload] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
			  {
				  if ([[key lowercaseString] isEqualToString:[kSessionid lowercaseString]])
				  {
					  sessionId = obj;
					  *stop = YES;
				  }
			  }];

			 NSNumber * sessionTimeOut = [[responseObject objectForKey:TCSAPIKey_payload]objectForKey:kSessionTimeout];

			 if (success)
			 {
				 success(sessionId, sessionTimeOut);
			 }
		 }
		 else
		 {
			 failure([responseObject objectForKey:kErrorMessage]);
		 }
	 }							  errorHandler:^(MKNetworkOperation *completedOperation, NSError *error)
	 {
		 if (failure)
		 {
			 failure(error);
		 }
	 }];

	[self.engine enqueueOperation:networkOperation];
}

- (void)api_sessionOnCompletion:(void (^)(NSString *, NSError *))onCompletionBlock
{
	[self path:TCSAPIPath_session
	withMethod:@"GET"
	parameters:nil
	parametersInjection:YES
		   addSessionId:NO
		   onCompletion:^(MKNetworkOperation *operation, id responseObject, NSError *error)
	{
		NSString * sessionId = [responseObject objectForKey:TCSAPIKey_payload];
		onCompletionBlock(sessionId, error);
	}];
}


#pragma mark -
#pragma mark - Confirmations

- (void)api_confirmWithSMSCode:(NSString *)smsCode
			  initialOperation:(NSString *)initialOperation
		initialOperationTicket:(NSString *)initialOperationTicket
			  confirmationType:(NSString *)confirmationType
					   success:(void (^)(MKNetworkOperation *operation))success
					   failure:(void (^)(NSError * error))failure
{
	NSString *confirmationData = [NSString stringWithFormat:@"{\"%@\":\"%@\"}",confirmationType,smsCode];

	NSDictionary * parameters = @{kInitialOperationTicket : initialOperationTicket,
								  kInitialOperation : initialOperation,
								  kConfirmationData : confirmationData};

	[self path:TCSAPIPath_confirm
	withMethod:@"GET"
	parameters:parameters
parametersInjection:YES
  addSessionId:YES
	   success:^(MKNetworkOperation *completedOperation, id responseObject)
	 {
		 if (success)
		 {
			 success(completedOperation);
		 }

	 }
	   failure:^(MKNetworkOperation *completedOperation, NSError *error)
	 {
		 if (failure)
		 {
			 failure(error);
		 }
	 }];
}

- (void)api_resendSMSCodeForInitialOperationTicket:(NSString *)initialOperationTicket
										   success:(void (^)())success
										   failure:(void (^)(NSError * error))failure
{
	NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
	[parameters setObject:kConfirmationTypeSMSBYID forKey:kConfirmationType];
	[parameters setObject:initialOperationTicket forKey:kInitialOperationTicket];


	[self path:TCSAPIPath_resendCode
	withMethod:@"GET"
	parameters:parameters
parametersInjection:YES
  addSessionId:YES
	   success:^(MKNetworkOperation *completedOperation, id responseObject)
	 {
		 if (success)
		 {
			 success();
		 }
	 }
	   failure:^(MKNetworkOperation *completedOperation, NSError *error)
	 {
		 if (failure)
		 {
			 failure(error);
		 }
	 }];

}


#pragma mark - 
#pragma mark - Reset

- (void)api_resetWalletSuccess:(void (^)())success
                       failure:(void (^)(NSError *error))failure
{
    [self path:TCSAPIPath_reset_wallet
    withMethod:@"GET"
    parameters:nil
parametersInjection:YES
  addSessionId:YES
       success:^(MKNetworkOperation *completedOperation, id responseObject)
     {
         if (success)
         {
             success();
         }
     }
       failure:^(MKNetworkOperation *completedOperation, NSError *error)
     {
         if (failure)
         {
             failure(error);
         }
     }];
}


#pragma mark -
#pragma mark - Sign Up
 
- (void)api_signUpWithPhoneNumber:(NSString *)phone
						 deviceId:(NSString *)deviceId
						  success:(void (^)(TCSSession * session))success
						  failure:(void (^)(NSError * error))failure
{

	NSDictionary * parameters = @{kPhone : phone,
								  kDeviceId : deviceId,
								  @"y": [UIDevice rootCheck]
								  };
	[self path:TCSAPIPath_sign_up
	withMethod:@"GET"
	parameters:parameters
parametersInjection:YES
  addSessionId:YES
	   success:^(MKNetworkOperation *completedOperation, id responseObject)
	 {
		 TCSSession * session = [[TCSSession alloc]initWithDictionary:[responseObject objectForKey:TCSAPIKey_payload]];

		 if (session)
		 {
			 if (success)
			 {
				 success(session);
			 }

			 [self performBlocksInQueue];
		 }
		 else
		 {
			 if (failure)
			 {
				 NSString * errorMessage = [responseObject objectForKey:kErrorMessage];
				 failure([NSError errorWithDomain:TCSErrorDomain code:TCSErrorCodeEmptyResult userInfo:@{kErrorMessage : errorMessage ?: @""}]);
			 }
		 }
	 }
	   failure:^(MKNetworkOperation *completedOperation, NSError *error)
	 {
		 if (failure)
		 {
			 failure(error);
		 }
	 }];
}

- (void)api_mobileSavePinWithDeviceId:(NSString *)deviceId
								  pin:(NSString *)pin
					   currentPinHash:(NSString *)currentPinHash
							  success:(void (^)(NSString * key))success
							  failure:(void (^)(NSError * error))failure
{
	NSString *pinHash = [pin md5];

	NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{kPinHash : pinHash,
																					  kDeviceId : deviceId,
																					  @"y" : [UIDevice rootCheck]
																					  }];
	if (currentPinHash)
	{
		[parameters setObject:currentPinHash forKey:currentPinHash];
	}

	[self path:TCSAPIPath_mobile_save_pin
	withMethod:@"GET"
	parameters:parameters
parametersInjection:YES
  addSessionId:YES
	   success:^(MKNetworkOperation *completedOperation, id responseObject)
	 {
		 if (success)
		 {
			 success(responseObject[TCSAPIKey_payload][kKey]);
		 }

		 [self performBlocksInQueue];
	 }
	   failure:^(MKNetworkOperation *completedOperation, NSError *error)
	 {
		 if (failure)
		 {
			 failure(error);
		 }
	 }];
}

- (void)api_mobileAuthWithDeviceId:(NSString *)deviceId
							   pin:(NSString *)pin
					  oldSessionId:(NSString *)oldSessionId
						   success:(void (^)(TCSSession * session, NSString * key))success
		   pinEnterAtteptsExceeded:(void (^)(TCSMillisecondsTimestamp *))pinEnterAttemptsExceeded
						   failure:(void (^)(NSError * error))failure
{

	NSString *pinHash = [pin md5];
	NSDictionary * parameters = @{kPinHash : pinHash,
								  kDeviceId : deviceId,
                                  kOldSessionId : oldSessionId ?: @"",
								  @"y" : [UIDevice rootCheck]};

	[self path:TCSAPIPath_mobile_auth
	withMethod:@"GET"
	parameters:parameters
parametersInjection:YES
  addSessionId:NO
	   success:^(__unused MKNetworkOperation *completedOperation, id responseObject)
	 {
		 TCSSession * session = [[TCSSession alloc]initWithDictionary:responseObject[TCSAPIKey_payload]];

		 if (success)
		 {
			 success(session,responseObject[TCSAPIKey_payload][kKey]);
		 }

		 [self performBlocksInQueue];
	 }
	   failure:^(MKNetworkOperation *completedOperation, NSError *error)
	 {
		 NSDictionary * blockUntilDictionary = [completedOperation responseJSON][TCSAPIKey_payload][kBlockedUntil];

		 if (blockUntilDictionary && pinEnterAttemptsExceeded)
		 {
			 TCSMillisecondsTimestamp * blockedUntill = [[TCSMillisecondsTimestamp alloc]initWithDictionary:blockUntilDictionary];
			 pinEnterAttemptsExceeded(blockedUntill);
		 }
			else if (failure)
			{
				failure(error);
			}
	 }];
}




#pragma mark -
#pragma mark - Config

- (void)api_configUpdateSuccess:(void (^)(NSDictionary * configPayloadDictionary))success
						failure:(void (^)(NSError * error))failure
{
	//вытаскиваем origin из общих параметров запроса, для того, чтобы универсально использовать его значение для платформ
	//mb - mobile, mk - wallet
    
	[self path:TCSAPIPath_config
	withMethod:@"GET"
	parameters:@{ kConfig : @"mtalk"}
parametersInjection:YES
  addSessionId:NO
	   success:^(MKNetworkOperation *completedOperation, id responseObject)
     {
         NSDictionary * configDictionary = [responseObject objectForKey:TCSAPIKey_payload];
         
         if (configDictionary)
         {
             if (success)
             {
                 success(configDictionary);
             }
         }
         else
         {
             if (failure)
             {
                 failure([responseObject objectForKey:kErrorMessage]);
             }
             
         }
     }
	   failure:^(MKNetworkOperation *completedOperation, NSError *error)
     {
         if (failure)
         {
             failure(error);
         }
     }];
}

- (void)configRequest:(void (^)(NSDictionary *configDictionary, NSError *error))onCompletion
{
	[self path:TCSAPIPath_config
	withMethod:TCSAPIClientMethodGET
	parameters:@{ kConfig : self.configuration.additionalCommonParameters[kOrigin] ?: @"undefined" }
	parametersInjection:YES
		   addSessionId:NO
		   onCompletion:^(MKNetworkOperation *completedOperation, id responseObject, NSError *error)
	{
		NSDictionary *configDictionary = responseObject[TCSAPIKey_payload];
		if (onCompletion) { onCompletion(configDictionary, error); }
	}];
}


#pragma mark -
#pragma mark - Feedback Message

- (void)api_feedbackPhonesSuccess:(void (^)(TCSFeedbackPhonesList * feedbackPhonesList))success
						  failure:(void (^)(NSError *error))failure;
{
	[self path:TCSAPIPath_feedback_phones
	withMethod:@"GET"
	parameters:nil
parametersInjection:YES
  addSessionId:YES
	   success:^(MKNetworkOperation *completedOperation, id responseObject)
     {
         if (success)
         {
             TCSFeedbackPhonesList * feedbackPhonesList = [[TCSFeedbackPhonesList alloc]initWithDictionary:responseObject];
             success(feedbackPhonesList);
         }
     }
	   failure:^(MKNetworkOperation *completedOperation, NSError *error)
     {
         if (failure)
         {
             failure(error);
         }
     }];
}

- (void)api_postFeedbackMessage:(NSString *)message email:(NSString *)email subject:(NSString *)subject type:(NSString *)type success:(void (^)())success
                        failure:(void (^)(NSError *))failure
{
	NSDictionary * parameters = @{kFeedbackEmail : email, kMessage : message, kFeedbackSubject: subject, kFeedbackType : type};
    
	[self path:TCSAPIPath_send_feedback_email
	withMethod:@"GET"
	parameters:parameters
parametersInjection:YES
  addSessionId:NO
	   success:^(MKNetworkOperation *completedOperation, id responseObject)
     {
         if (success)
         {
             success();
         }
     }
	   failure:^(MKNetworkOperation *completedOperation, NSError *error)
     {
         if (failure)
         {
             failure(error);
         }
     }];
}

- (void)api_feedbackTopicsSuccess:(void (^)(TCSFeedbackTopicsList *))success failure:(void (^)(NSError *))failure
{
	[self path:TCSAPIPath_feedback_email_topics
	withMethod:@"GET"
	parameters:nil
parametersInjection:YES
  addSessionId:YES
	   success:^(MKNetworkOperation *completedOperation, id responseObject)
     {
         if (success && responseObject)
         {
             TCSFeedbackTopicsList * feedbackTopicsList = [[TCSFeedbackTopicsList alloc]initWithDictionary:responseObject];
             success(feedbackTopicsList);
         }
     }
	   failure:^(MKNetworkOperation *completedOperation, NSError *error)
     {
         if (failure)
         {
             failure(error);
         }
     }];
}


#pragma mark -
#pragma mark - Transfer

- (void)api_transferFromCard3DS:(NSString *)cardId
                      accountId:(NSString *)accountId
                    moneyAmount:(NSString *)moneyAmount
                moneyCommission:(NSString *)moneyCommission
                        success:(void (^)(NSString *paymentId))success
                        failure:(void (^)(NSError *error))failure
{
    if (accountId == nil && failure)
    {
        failure([NSError errorWithDomain:TCSErrorDomain code:TCSErrorCodeInvalidArgument userInfo:@{kErrorMessage :LOC(@"accountRequisites_error_accountIsNil")}]);
        return;
    }
    
    NSDictionary *parameters = @{
								 kCardId : cardId,
								 TCSAPIKey_moneyAmount : moneyAmount,
                                 kAccount : accountId ? : @"",
								 kMoneyCommission : (moneyCommission.length > 0 ?  moneyCommission : @"0")
								 };
    
    [self path:TCSAPIPath_transfer_from_card_3ds
    withMethod:@"GET"
    parameters:parameters
parametersInjection:YES
  addSessionId:YES
       success:^(MKNetworkOperation *completedOperation, id responseObject)
	 {
         if (success)
         {
             NSString *paymentId = responseObject[TCSAPIKey_payload][kPaymentId];
             success(paymentId);
         }
	 }
       failure:^(MKNetworkOperation *completedOperation, NSError *error)
	 {
		 if (failure)
		 {
			 failure(error);
		 }
	 }];
}

- (void)api_transferFromCard3DS:(NSString *)cardNumber
                      accountId:(NSString *)accountId
                     expiryDate:(NSString *)expiryDate
					 cardholder:(NSString *)cardholder
                   securityCode:(NSString *)securityCode
                    moneyAmount:(NSString *)moneyAmount
                moneyCommission:(NSString *)moneyCommission
                        success:(void (^)(NSString *paymentId))success
                        failure:(void (^)(NSError *error))failure
{
    [self api_transferFromCard3DS:cardNumber
						accountId:accountId
					   expiryDate:expiryDate
					   cardholder:cardholder
					 securityCode:securityCode
					  moneyAmount:moneyAmount
				  moneyCommission:moneyCommission
					   attachCard:NO
						 cardName:nil
						  success:success
						  failure:failure];
}

- (void)api_transferFromCard3DS:(NSString *)cardNumber
                      accountId:(NSString *)accountId
                     expiryDate:(NSString *)expiryDate
                     cardholder:(NSString *)cardholder
                   securityCode:(NSString *)securityCode
                    moneyAmount:(NSString *)moneyAmount
                moneyCommission:(NSString *)moneyCommission
					 attachCard:(BOOL)attachCard
                       cardName:(NSString *)cardName
                        success:(void (^)(NSString *paymentId))success
                        failure:(void (^)(NSError *error))failure
{
    if (accountId == nil && failure)
    {
        failure([NSError errorWithDomain:TCSErrorDomain code:TCSErrorCodeInvalidArgument userInfo:@{kErrorMessage :LOC(@"accountRequisites_error_accountIsNil")}]);
        return;
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{
																					  TCSAPIKey_cardNumber : cardNumber,
																					  TCSAPIKey_moneyAmount : moneyAmount,
																					  kMoneyCommission : (moneyCommission.length > 0 ?  moneyCommission : @"0")
																					  }];
    
    if (cardholder)
    {
        parameters[TCSAPIKey_cardholder] = cardholder;
    }
    if (accountId)
    {
        parameters[kAccount] = accountId;
    }
    
    if (expiryDate)
    {
        parameters[TCSAPIKey_expiryDate] = expiryDate;
    }
    
    if (securityCode)
    {
        parameters[TCSAPIKey_securityCode] = securityCode;
    }
    
    if (attachCard)
    {
        [parameters setObject:kTrue forKey:kattachCard];
        [parameters setObject:cardName forKey:TCSAPIKey_cardName];
    }
    
    [self path:TCSAPIPath_transfer_from_card_3ds
    withMethod:@"GET"
    parameters:parameters
parametersInjection:YES
  addSessionId:YES
       success:^(MKNetworkOperation *completedOperation, id responseObject)
	 {
         if (success)
         {
             NSString *paymentId = responseObject[TCSAPIKey_payload][kPaymentId];
             success(paymentId);
         }
	 }
       failure:^(MKNetworkOperation *completedOperation, NSError *error)
	 {
		 if (failure)
		 {
			 failure(error);
		 }
	 }];
}

- (void)api_attachCard:(NSString *)cardNumber
            expiryDate:(NSString *)expiryDate
            cardholder:(NSString *)cardholder
          securityCode:(NSString *)securityCode
              cardName:(NSString *)cardName
               success:(void (^)(NSString *))success
               failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{
																					  TCSAPIKey_cardNumber : cardNumber,
                                                                                      TCSAPIKey_cardName : cardName
                                                                                      }];
    if (expiryDate)
    {
        parameters[TCSAPIKey_expiryDate] = expiryDate;
    }
    
    if (securityCode)
    {
        parameters[TCSAPIKey_securityCode] = securityCode;
    }

    if (cardholder) {
        parameters[TCSAPIKey_cardholder]= cardholder;
    }
    
    [self path:TCSAPIPath_attach_card
    withMethod:@"GET"
    parameters:parameters
parametersInjection:YES
  addSessionId:YES
       success:^(MKNetworkOperation *completedOperation, id responseObject)
	 {
         
         if (success)
         {
             NSString *cardId = responseObject[TCSAPIKey_payload][kCardId];
             
             success(cardId);
         }
	 }
       failure:^(MKNetworkOperation *completedOperation, NSError *error)
	 {
		 if (failure)
		 {
			 failure(error);
		 }
	 }];
}

- (void)api_transferAnyCardWithCardNumber:(NSString *)cardNumber
                             expirityDate:(NSString *)expirityDate
                             securityCode:(NSString *)securityCode
                                 orCardId:(NSString *)cardId
                             toCardNumber:(NSString *)toCardNumber
                              moneyAmount:(NSString *)moneyAmount
                                 currency:(NSString *)currency
                             templateName:(NSString *)templateName
                                  success:(void (^)(NSString *))success
                                  failure:(void (^)(NSError *))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    
    if ([cardId length])
    {
        parameters[kCardId] = cardId;
    }
    else
    {
        if (cardNumber)
        {
            parameters[TCSAPIKey_cardNumber] = cardNumber;
        }
        
        if (expirityDate)
        {
            parameters[TCSAPIKey_expiryDate] = expirityDate;
        }
        
        if (securityCode)
        {
            parameters[TCSAPIKey_securityCode] = securityCode;
        }
    }
    
    if (toCardNumber)
    {
        parameters[kToCardNumber] = toCardNumber;
    }
    
    if (moneyAmount)
    {
        parameters[TCSAPIKey_moneyAmount] = moneyAmount;
    }
    
    if (currency)
    {
        parameters[kCurrency] = currency;
    }
    
    if ([templateName length])
    {
        parameters[kCreateTemplate] = kTrue;
        parameters[TCSAPIKey_name] = templateName;
    }
    
    [self path:TCSAPIPath_transfer_any_card_to_any_card
    withMethod:TCSAPIClientMethodGET
    parameters:parameters
parametersInjection:YES
  addSessionId:YES
       success:^(MKNetworkOperation *completedOperation, id responseObject)
     {
         
         if (success)
         {
             NSString *paymentId = responseObject[TCSAPIKey_payload][kPaymentId];
             
             success(paymentId);
         }
     }
       failure:^(MKNetworkOperation *completedOperation, NSError *error)
     {
         if (failure)
         {
             failure(error);
         }
     }];
}

- (void)api_transferAnyCardToAnyPointerWithCardNumber:(NSString *)cardNumber					//✔ *2 Номер непривязанной карты, с которой переводятся деньги
										   cardHolder:(NSString *)cardHolder					//  *2 Имя владельца карты
										 securityCode:(NSString *)securityCode					//✔ *2 CVV
										 expirityDate:(NSString *)expirityDate					//✔ *2 Дата окончания срока действя карты, ММ/ГГ
							   sourceNetworkAccountId:(NSString *)sourceNetworkAccountId		//✔ Идентификатор отправителя (номер телефона, email, id в социальной сети)
									  sourceNetworkId:(NSString *)sourceNetworkId				//✔ Обозначение социальной сети: mobile, email, vk или fb.
										   sourceName:(NSString *)sourceName					//  Имя отправителя для отображения другу
						  destinationNetworkAccountId:(NSString *)destinationNetworkAccountId	//✔ Идентификатор получателя (номер телефона, email, id в социальной сети)
								 destinationNetworkId:(NSString *)destinationNetworkId			//✔ Обозначение социальной сети: mobile, email, vk или fb.
									  destinationName:(NSString *)destinationName				//  Имя получателя перевода
										  moneyAmount:(NSString *)moneyAmount					//✔ Отправляемая сумма
											 currency:(NSString *)currency						//✔ Валюта перевода
											  message:(NSString *)message						//Сообщение получателю, будет добавлено к уведомлению о переводе.
											  imageId:(NSString *)imageId						//Идентификатор приложенной картинки. Картинка должна храниться на шаре и ссылка на неё будет формироваться в соответствии со статьёй Вложения
											  invoice:(NSString *)invoice						//Идентификатор запроса денег для обозначения того, что указанный перевод удовлетворял обозначенный в параметре запрос.
												  ttl:(NSString *)ttl							//Время жизни короткой ссылки. Если параметр отсутствует, будет взято значение из конфига по ключу service.shortLink.ttl. Если значения нет и в конфиге, ссылка будет действительна в течение 24 часов.
										   completion:(void (^)(NSString *, NSString *, NSError *))completion
{
	[self api_transferAnyCardToAnyPointerWithCardId:nil
										 cardNumber:cardNumber
										 cardHolder:cardHolder
									   securityCode:securityCode
									   expirityDate:expirityDate
							 sourceNetworkAccountId:sourceNetworkAccountId
									sourceNetworkId:sourceNetworkId
										 sourceName:sourceName
						destinationNetworkAccountId:destinationNetworkAccountId
							   destinationNetworkId:destinationNetworkId
									destinationName:destinationName
										moneyAmount:moneyAmount
										   currency:currency
											message:message
											imageId:imageId
											invoice:invoice
												ttl:ttl
										 completion:completion];
}

- (void)api_transferAnyCardToAnyPointerWithCardId:(NSString *)cardId							//✔ *1 ID привязанной карты, с которой переводятся деньги.
                                     securityCode:(NSString *)securityCode                      // CVV
						   sourceNetworkAccountId:(NSString *)sourceNetworkAccountId			//✔ Идентификатор отправителя (номер телефона, email, id в социальной сети)
								  sourceNetworkId:(NSString *)sourceNetworkId					//✔ Обозначение социальной сети: mobile, email, vk или fb.
									   sourceName:(NSString *)sourceName						// Имя отправителя для отображения другу
					  destinationNetworkAccountId:(NSString *)destinationNetworkAccountId		//✔ Идентификатор получателя (номер телефона, email, id в социальной сети)
							 destinationNetworkId:(NSString *)destinationNetworkId				//✔ Обозначение социальной сети: mobile, email, vk или fb.
								  destinationName:(NSString *)destinationName					// Имя получателя перевода
									  moneyAmount:(NSString *)moneyAmount						//✔ Отправляемая сумма
										 currency:(NSString *)currency							//✔ Валюта перевода
										  message:(NSString *)message							//Сообщение получателю, будет добавлено к уведомлению о переводе.
										  imageId:(NSString *)imageId							//Идентификатор приложенной картинки. Картинка должна храниться на шаре и ссылка на неё будет формироваться в соответствии со статьёй Вложения
										  invoice:(NSString *)invoice							//Идентификатор запроса денег для обозначения того, что указанный перевод удовлетворял обозначенный в параметре запрос.
											  ttl:(NSString *)ttl								//Время жизни короткой ссылки. Если параметр отсутствует, будет взято значение из конфига по ключу service.shortLink.ttl. Если значения нет и в конфиге, ссылка будет действительна в течение 24 часов.
									   completion:(void (^)(NSString *paymentId, NSString *status, NSError *error))completion
{
	[self api_transferAnyCardToAnyPointerWithCardId:cardId
										 cardNumber:nil
										 cardHolder:nil
									   securityCode:securityCode
									   expirityDate:nil
							 sourceNetworkAccountId:sourceNetworkAccountId
									sourceNetworkId:sourceNetworkId
										 sourceName:sourceName
						destinationNetworkAccountId:destinationNetworkAccountId
							   destinationNetworkId:destinationNetworkId
									destinationName:destinationName
										moneyAmount:moneyAmount
										   currency:currency
											message:message
											imageId:imageId
											invoice:invoice
												ttl:ttl
										 completion:completion];
}

- (void)api_transferAnyCardToAnyPointerWithCardId:(NSString *)cardId						//✔ *1 ID привязанной карты, с которой переводятся деньги.
									   cardNumber:(NSString *)cardNumber					//✔ *2 Номер непривязанной карты, с которой переводятся деньги
									   cardHolder:(NSString *)cardHolder					//  *2 Имя владельца карты
									 securityCode:(NSString *)securityCode					//✔ *2 CVV
									 expirityDate:(NSString *)expirityDate					//✔ *2 Дата окончания срока действя карты, ММ/ГГ
						   sourceNetworkAccountId:(NSString *)sourceNetworkAccountId		//✔ Идентификатор отправителя (номер телефона, email, id в социальной сети)
								  sourceNetworkId:(NSString *)sourceNetworkId				//✔ Обозначение социальной сети: mobile, email, vk или fb.
									   sourceName:(NSString *)sourceName					//  Имя отправителя для отображения другу
					  destinationNetworkAccountId:(NSString *)destinationNetworkAccountId	//✔ Идентификатор получателя (номер телефона, email, id в социальной сети)
							 destinationNetworkId:(NSString *)destinationNetworkId			//✔ Обозначение социальной сети: mobile, email, vk или fb.
								  destinationName:(NSString *)destinationName				//  Имя получателя перевода
									  moneyAmount:(NSString *)moneyAmount					//✔ Отправляемая сумма
										 currency:(NSString *)currency						//✔ Валюта перевода
										  message:(NSString *)message						//Сообщение получателю, будет добавлено к уведомлению о переводе.
										  imageId:(NSString *)imageId						//Идентификатор приложенной картинки. Картинка должна храниться на шаре и ссылка на неё будет формироваться в соответствии со статьёй Вложения
										  invoice:(NSString *)invoice						//Идентификатор запроса денег для обозначения того, что указанный перевод удовлетворял обозначенный в параметре запрос.
											  ttl:(NSString *)ttl							//Время жизни короткой ссылки. Если параметр отсутствует, будет взято значение из конфига по ключу service.shortLink.ttl. Если значения нет и в конфиге, ссылка будет действительна в течение 24 часов.
									   completion:(void (^)(NSString * paymentId, NSString * status, NSError * error))completion
{
	NSMutableDictionary * parameters = [NSMutableDictionary dictionary];

	if (cardId)
	{
		[parameters setObject:cardId forKey:kCardId];
	}

	if (cardNumber)
	{
		[parameters setObject:cardNumber forKey:TCSAPIKey_cardNumber];
	}

	if (cardHolder)
	{
		[parameters setObject:cardHolder forKey:TCSAPIKey_cardholder];
	}

	if (securityCode)
	{
		[parameters setObject:securityCode forKey:TCSAPIKey_securityCode];
	}

	if (expirityDate)
	{
		[parameters setObject:expirityDate forKey:TCSAPIKey_expiryDate];
	}

	if (sourceNetworkAccountId)
	{
		[parameters setObject:sourceNetworkAccountId forKey:kSrcAccountId];
	}

	if (sourceNetworkId)
	{
		[parameters setObject:sourceNetworkId forKey:kSrcNetworkId];
	}

	if (sourceName)
	{
		[parameters setObject:sourceName forKey:kSrcName];
	}

	if (destinationNetworkAccountId)
	{
		[parameters setObject:destinationNetworkAccountId forKey:kDstAccountId];
	}

	if (destinationNetworkId)
	{
		[parameters setObject:destinationNetworkId forKey:kDstNetworkId];
	}

	if (destinationName)
	{
		[parameters setObject:destinationName forKey:kDstName];
	}

	if (moneyAmount)
	{
		[parameters setObject:moneyAmount forKey:TCSAPIKey_moneyAmount];
	}

	if (currency)
	{
		[parameters setObject:currency forKey:kCurrency];
	}

	if (message)
	{
		[parameters setObject:message forKey:kMessage];
	}

	if (imageId)
	{
		[parameters setObject:imageId forKey:TCSAPIKey_image];
	}

	if (invoice)
	{
		[parameters setObject:invoice forKey:kInvoice];
	}

	if (ttl)
	{
		[parameters setObject:ttl forKey:kTtl];
	}

    [self path:TCSAPIPath_transfer_any_card_to_any_pointer
    withMethod:TCSAPIClientMethodGET
    parameters:parameters
parametersInjection:YES
  addSessionId:YES
  onCompletion:^(MKNetworkOperation *completedOperation, id responseObject, NSError *error)
     {
         NSDictionary *payload = responseObject[TCSAPIKey_payload];

         if (error)
         {
			 if (completion) completion(nil, nil, error);
         }
         else
         {
             if (completion) completion(payload[kPaymentId], payload[kStatus], nil);
         }
     }];
}


#pragma mark -
#pragma mark - Accounts

- (void)api_accountsListSuccess:(void (^)(TCSAccountGroupsList * groupsList))success
						failure:(void (^)(NSError * error))failure
{
	[self path:TCSAPIPath_accounts
	withMethod:@"GET"
	parameters:nil
parametersInjection:YES
  addSessionId:YES
	   success:^(MKNetworkOperation *completedOperation, id responseObject)
     {
         TCSAccountGroupsList * groupsList = [[TCSAccountGroupsList alloc]initWithDictionary:responseObject];
         success(groupsList);
     }
	   failure:^(MKNetworkOperation *completedOperation, NSError *error)
     {
         if (failure)
         {
             failure(error);
         }
     }];
    
}


#pragma mark -
#pragma mark - Commission

- (void)api_commissionLoadWithAccountId:(NSString *)accountId
                             cardNumber:(NSString *)cardNumber
                                 cardId:(NSString *)cardId
                            paymentType:(NSString *)paymentType
                             providerId:(NSString *)providerId
                             templateId:(NSString *)templateId
                         currencyString:(NSString *)currencyString
                         amountAsString:(NSString *)amountAsString
                         providerFields:(NSArray *)providerFields
                                success:(void (^)(TCSCommission * commission))success
                                failure:(void (^)(NSError * error))failure
{
//    if (accountId == nil && failure)
//    {
//        failure([NSError errorWithDomain:TCSErrorDomain code:TCSErrorCodeInvalidArgument userInfo:@{kErrorMessage :LOC(@"accountRequisites_error_accountIsNil")}]);
//        return;
//    }
    
    
    NSDictionary * paramsBase = @{kPaymentType : (paymentType ? paymentType : @""),
                                  kProvider : (providerId ? providerId : @""),
                                  kCurrency : (currencyString ? currencyString : @""),
                                  TCSAPIKey_moneyAmount : (amountAsString ? amountAsString : @"")
                                  };
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:paramsBase];
    
    if (accountId)
    {
        [params setObject:accountId forKey:kAccount];
    }
    else if (cardId)
    {
        [params setObject:cardId forKey:kCardId];
    }
    else if (cardNumber)
    {
        [params setObject:cardNumber forKey:TCSAPIKey_cardNumber];
    }
    
    if (templateId.length > 0)
    {
        [params setObject:templateId forKey:kTemplate];
    }
    
    for (NSDictionary *providerFieldDic in providerFields)
    {
        NSString *keyString = [NSString stringWithFormat:@"field%@",[providerFieldDic objectForKey:TCSAPIKey_id]];
        NSString *value = [providerFieldDic objectForKey:TCSAPIKey_value];
        if (value == nil)
        {
            value = [providerFieldDic objectForKey:kDefaultValue];
        }
        [params setObject:value == nil ? @"" : value forKey:keyString];
    }
    
    [self path:TCSAPIPath_payment_commission
    withMethod:@"GET"
    parameters:params
parametersInjection:YES
  addSessionId:YES
       success:^(MKNetworkOperation *completedOperation, id responseObject)
     {
         responseObject = responseObject[TCSAPIKey_payload];
         
         if (success && responseObject)
         {
             TCSCommission * commission = [[TCSCommission alloc]initWithDictionary:responseObject];
             success(commission);
         }
     }
       failure:^(MKNetworkOperation *completedOperation, NSError *error)
     {
         if (failure)
         {
             failure(error);
         }
     }];
}

- (void)api_commissionLoadWithAccountId:(NSString *)accountId
                            paymentType:(NSString *)paymentType
                             providerId:(NSString *)providerId
                             templateId:(NSString *)templateId
                         currencyString:(NSString *)currencyString
                         amountAsString:(NSString *)amountAsString
                         providerFields:(NSArray *)providerFields
                                success:(void (^)(TCSCommission * commission))success
                                failure:(void (^)(NSError * error))failure
{
    [self api_commissionLoadWithAccountId:accountId
                               cardNumber:nil
                                   cardId:nil
                              paymentType:paymentType
                               providerId:providerId
                               templateId:templateId
                           currencyString:currencyString
                           amountAsString:amountAsString
                           providerFields:providerFields
                                  success:success
                                  failure:failure];
}

- (void)api_commissionLoadWithCardId:(NSString *)cardId
                         paymentType:(NSString *)paymentType
                          providerId:(NSString *)providerId
                          templateId:(NSString *)templateId
                      currencyString:(NSString *)currencyString
                      amountAsString:(NSString *)amountAsString
                      providerFields:(NSArray *)providerFields
                             success:(void (^)(TCSCommission * commission))success
                             failure:(void (^)(NSError * error))failure
{
    [self api_commissionLoadWithAccountId:nil
                               cardNumber:nil
                                   cardId:cardId
                              paymentType:paymentType
                               providerId:providerId
                               templateId:templateId
                           currencyString:currencyString
                           amountAsString:amountAsString
                           providerFields:providerFields
                                  success:success
                                  failure:failure];
}

- (void)api_commissionLoadWithCardNumber:(NSString *)cardNumber
                             paymentType:(NSString *)paymentType
                              providerId:(NSString *)providerId
                              templateId:(NSString *)templateId
                          currencyString:(NSString *)currencyString
                          amountAsString:(NSString *)amountAsString
                          providerFields:(NSArray *)providerFields
                                 success:(void (^)(TCSCommission * commission))success
                                 failure:(void (^)(NSError * error))failure
{
    [self api_commissionLoadWithAccountId:nil
                               cardNumber:cardNumber
                                   cardId:nil
                              paymentType:paymentType
                               providerId:providerId
                               templateId:templateId
                           currencyString:currencyString
                           amountAsString:amountAsString
                           providerFields:providerFields
                                  success:success
                                  failure:failure];
}



#pragma mark -
#pragma mark - Test Request SMS Code

- (void)api_testRequestSMSCodeWithOperationTicket:(NSString *)initialOperationTicket
                                 confirmationType:(NSString *)confirmationType
                                          success:(void (^)(NSString *securityCode))success
                                          failure:(void (^)(NSString * errorString))failure
{
	NSMutableDictionary * parameters = [NSMutableDictionary dictionaryWithDictionary:self.configuration.additionalCommonParameters];
	if (self.configuration.sessionId.length > 0)
	{
		parameters[kSessionid] = self.configuration.sessionId;
	}
	parameters[kInitialOperationTicket] = initialOperationTicket;

	NSString * url = API_url_for_confirmation_test;

	if ([self respondsToSelector:@selector(testConfirmationCodeRequestURL)])
	{
		url = [self.configuration testConfirmationCodeRequestURL];
	}

	if ([self respondsToSelector:@selector(testConfirmationCodeRequestAdditionalParameters)])
	{
		[parameters addEntriesFromDictionary:[self.configuration testConfirmationCodeRequestAdditionalParameters]];
	}

	MKNetworkOperation * networkOperation = [self.engine operationWithURLString:url
																		 params:parameters];
	
    [networkOperation addCompletionHandler:^(MKNetworkOperation *completedOperation)
	 {
		 DLog(@"%@",completedOperation);
		 if (success)
		 {
			 id responseObject = [completedOperation responseJSON];
			 id payload = responseObject[TCSAPIKey_payload];
			 NSString * securityCode = payload[0][TCSAPIKey_value];
			 success(securityCode);
		 }
	 }
                              errorHandler:^(MKNetworkOperation *completedOperation, NSError *error)
	 {
		 if (failure)
		 {
			 failure([TCSAPIClient messageFromError:error]);
		 }
	 }];
    
	[self.engine enqueueOperation:networkOperation];
}


#pragma mark -
#pragma mark Test Confirmation

- (void)api_confirmWithSMSCode:(NSString *)smsCode
			  initialOperation:(NSString *)initialOperation
		initialOperationTicket:(NSString *)initialOperationTicket
              confirmationType:(NSString *)confirmationType
                     sessionId:(NSString *)sessionId
					   success:(void (^)(MKNetworkOperation * completedOperation))success
					   failure:(void (^)(NSError * error))failure
{
	NSDictionary * parameters = @{kInitialOperationTicket : initialOperationTicket,
                                  kInitialOperation : initialOperation,
                                  kConfirmationType : confirmationType,
                                  kSecretValue : smsCode,
                                  kSessionId : sessionId};
    
	[self path:TCSAPIPath_confirm
	withMethod:@"GET"
	parameters:parameters
parametersInjection:YES
  addSessionId:YES
	   success:^(MKNetworkOperation *completedOperation, id responseObject)
     {
         if (success)
         {
             success(completedOperation);
         }
     }
	   failure:^(MKNetworkOperation *completedOperation, NSError *error)
     {
         if (failure)
         {
             failure(error);
         }
     }];
}


#pragma mark -
#pragma mark - Server Time

- (void)api_now:(void (^)(NSTimeInterval serverTime, NSError *error))completion
{
    void (^requestCompletion)(MKNetworkOperation *, id, NSError *) = ^(MKNetworkOperation *completedOperation, id responseObject, NSError *error)
    {
        if (error == nil && responseObject && completion)
        {
            NSDictionary * const responseDictionary = responseObject;
            NSParameterAssert([responseDictionary isKindOfClass:[NSDictionary class]]);
            
            NSTimeInterval serverTime = [responseDictionary[kPayload][kMilliseconds] doubleValue]/1000;
            completion(serverTime, error);
        }
        else if (error)
        {
            ALog(@"%@",error.localizedDescription);
        }
    };
    
    [self path:API_now
    withMethod:@"GET"
    parameters:nil
parametersInjection:YES
  addSessionId:NO
  onCompletion:requestCompletion];
}


- (void)api_cardDetachCardWithCardId:(NSString *)cardId
                             success:(void (^)())success
                             failure:(void (^)(NSError *))failure
{
    NSDictionary * parameters = @{kCardId : cardId ?: @""};
    
    [self path:TCSAPIPath_detach_card
    withMethod:@"GET"
    parameters:parameters
parametersInjection:YES
  addSessionId:YES
       success:^(MKNetworkOperation * completedOperation, id responseObject)
     {
         if (success)
         {
             success();
         }
     }
       failure:^(MKNetworkOperation *operation, NSError *error)
     {
         if (failure)
         {
             failure(error);
         }
     }];
}

- (void)api_setLinkedCardPrimary:(NSString *)cardId
                         success:(void (^)())success
                         failure:(void (^)(NSError *error))failure
{
    [self path:TCSAPIPath_set_linked_card_primary
    withMethod:@"GET"
    parameters:@{kCardId : cardId}
parametersInjection:YES
  addSessionId:YES
       success:^(MKNetworkOperation *completedOperation, id responseObject)
     {
         if (success)
         {
             success();
         }
     }
       failure:^(MKNetworkOperation *completedOperation, NSError *error)
     {
         if (failure)
         {
             failure(error);
         }
     }];
}

#pragma mark -
#pragma mark - Logging

- (void)api_logErrorWithDescription:(NSString *)description
{
    if (description == nil || ![description length])
    {
        return;
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    
    parameters[kMessage] = description;
    parameters[kComponent] = kApi; // constant
    parameters[kLevel] = kError; // constant
    
    [self path:TCSAPIPath_log
    withMethod:@"POST"
    parameters:parameters
parametersInjection:YES
  addSessionId:YES
       success:^(MKNetworkOperation *completedOperation, id responseObject)
     {
         
     }
       failure:^(MKNetworkOperation *completedOperation, NSError *error)
     {
         
     }];
}


@end
