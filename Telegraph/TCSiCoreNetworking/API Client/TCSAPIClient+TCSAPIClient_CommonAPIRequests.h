//
//  TCSAPIClient+TCSAPIClient_CommonAPIRequests.h
//  TCSiCore
//
//  Created by a.v.kiselev on 28/07/14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSAPIClient.h"

@interface TCSAPIClient (TCSAPIClient_CommonAPIRequests)

#pragma mark -
#pragma mark - Session, Auth

- (void)api_getSessionIdWithUsername:(NSString *)username
							password:(NSString *)password
							deviceId:(NSString *)deviceId
							 success:(void (^)(NSString * sessionId, NSNumber * sessionTimeout))success
							 failure:(void (^)(NSError *))failure;

- (void)api_sessionOnCompletion:(void (^)(NSString * sessionId, NSError * error))onCompletionBlock;


#pragma mark -
#pragma mark - Confirmation

- (void)api_confirmWithSMSCode:(NSString*)smsCode
			  initialOperation:(NSString*)initialOperation
		initialOperationTicket:(NSString*)initialOperationTicket
			  confirmationType:(NSString *)confirmationType
					   success:(void (^)(MKNetworkOperation *operation))success
					   failure:(void (^)(NSError * error))failure;

- (void)api_resendSMSCodeForInitialOperationTicket:(NSString*)initialOperationTicket
										   success:(void (^)())success
										   failure:(void (^)(NSError * error))failure;


#pragma mark -
#pragma mark - Reset

- (void)api_resetWalletSuccess:(void (^)())success
                       failure:(void (^)(NSError *error))failure;


#pragma mark -
#pragma mark - Sign Up

- (void)api_signUpWithPhoneNumber:(NSString *)phone
						 deviceId:(NSString *)deviceId
						  success:(void (^)(TCSSession * session))success
						  failure:(void (^)(NSError * error))failure;

- (void)api_mobileSavePinWithDeviceId:(NSString *)deviceId
								  pin:(NSString *)pin
					   currentPinHash:(NSString*)currentPinHash
							  success:(void (^)(NSString * key))success
							  failure:(void (^)(NSError * error))failure;

- (void)api_mobileAuthWithDeviceId:(NSString *)deviceId
							   pin:(NSString *)pin
					  oldSessionId:(NSString *)oldSessionId
						   success:(void (^)(TCSSession * session, NSString * key))success
		   pinEnterAtteptsExceeded:(void (^)(TCSMillisecondsTimestamp * blockedUntil))pinEnterAttemptsExceeded
						   failure:(void (^)(NSError * error))failure;


#pragma mark -
#pragma mark - Config

- (void)api_configUpdateSuccess:(void (^)(NSDictionary * configPayloadDictionary))success
						failure:(void (^)(NSError * error))failure;

- (void)configRequest:(void (^)(NSDictionary *configDictionary, NSError *error))onCompletion;


#pragma mark -
#pragma mark - Feedback

- (void)api_feedbackPhonesSuccess:(void (^)(TCSFeedbackPhonesList * feedbackPhonesList))success
						  failure:(void (^)(NSError *error))failure;

- (void)api_postFeedbackMessage:(NSString *)message
						  email:(NSString *)email
						subject:(NSString *)subject
						   type:(NSString *)type
						success:(void (^)())success
						failure:(void (^)(NSError *))failure;

- (void)api_feedbackTopicsSuccess:(void (^)(TCSFeedbackTopicsList *))success
						  failure:(void (^)(NSError *))failure;


#pragma mark -
#pragma mark - Transfer

- (void)api_transferFromCard3DS:(NSString *)cardId
                      accountId:(NSString *)accountId
                    moneyAmount:(NSString *)moneyAmount
                moneyCommission:(NSString *)moneyCommission
                        success:(void (^)(NSString *paymentId))success
                        failure:(void (^)(NSError *error))failure;

- (void)api_transferFromCard3DS:(NSString *)cardNumber
                      accountId:(NSString *)accountId
                     expiryDate:(NSString *)expiryDate
                     cardholder:(NSString *)cardholder
                   securityCode:(NSString *)securityCode
                    moneyAmount:(NSString *)moneyAmount
                moneyCommission:(NSString *)moneyCommission
                        success:(void (^)(NSString *paymentId))success
                        failure:(void (^)(NSError *error))failure;

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
                        failure:(void (^)(NSError *error))failure;

- (void)api_attachCard:(NSString *)cardNumber
            expiryDate:(NSString *)expiryDate
            cardholder:(NSString *)cardholder
          securityCode:(NSString *)securityCode
              cardName:(NSString *)cardName
               success:(void (^)(NSString *cardId))success
               failure:(void (^)(NSError *error))failure;

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
										   completion:(void (^)(NSString *paymentId, NSString *status, NSError *error))completion;

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
									   completion:(void (^)(NSString *paymentId, NSString *status, NSError *error))completion;

- (void)api_transferAnyCardWithCardNumber:(NSString *)cardNumber
                             expirityDate:(NSString *)expirityDate
                             securityCode:(NSString *)securityCode
                                 orCardId:(NSString *)cardId
                             toCardNumber:(NSString *)toCardNumber
                              moneyAmount:(NSString *)moneyAmount
                                 currency:(NSString *)currency
                             templateName:(NSString *)templateName
                                  success:(void (^)(NSString *))success
                                  failure:(void (^)(NSError *))failure;

#pragma mark -
#pragma mark - Accounts

- (void)api_accountsListSuccess:(void (^)(TCSAccountGroupsList * groupsList))success
						failure:(void (^)(NSError * error))failure;



#pragma mark -
#pragma mark - Commission

- (void)api_commissionLoadWithCardId:(NSString *)cardId
                         paymentType:(NSString *)paymentType
                          providerId:(NSString *)providerId
                          templateId:(NSString *)templateId
                      currencyString:(NSString *)currencyString
                      amountAsString:(NSString *)amountAsString
                      providerFields:(NSArray *)providerFields
                             success:(void (^)(TCSCommission * commission))success
                             failure:(void (^)(NSError * error))failure;

- (void)api_commissionLoadWithCardNumber:(NSString *)cardNumber
                             paymentType:(NSString *)paymentType
                              providerId:(NSString *)providerId
                              templateId:(NSString *)templateId
                          currencyString:(NSString *)currencyString
                          amountAsString:(NSString *)amountAsString
                          providerFields:(NSArray *)providerFields
                                 success:(void (^)(TCSCommission * commission))success
                                 failure:(void (^)(NSError * error))failure;

#pragma mark -
#pragma mark - Test Request SMS Code

- (void)api_testRequestSMSCodeWithOperationTicket:(NSString *)initialOperationTicket
                                 confirmationType:(NSString *)confirmationType
                                          success:(void (^)(NSString *securityCode))success
                                          failure:(void (^)(NSString * errorString))failure;


#pragma mark -
#pragma mark - Test Confirmation

- (void)api_confirmWithSMSCode:(NSString *)smsCode
			  initialOperation:(NSString *)initialOperation
		initialOperationTicket:(NSString *)initialOperationTicket
              confirmationType:(NSString *)confirmationType
                     sessionId:(NSString *)sessionId
					   success:(void (^)(MKNetworkOperation * completedOperation))success
					   failure:(void (^)(NSError * error))failure;



#pragma mark -
#pragma mark - Server Time

- (void)api_now:(void (^)(NSTimeInterval serverTime, NSError *error))completion;


- (void)api_cardDetachCardWithCardId:(NSString *)cardId
                             success:(void (^)())success
                             failure:(void (^)(NSError *))failure;

- (void)api_setLinkedCardPrimary:(NSString *)cardId
                         success:(void (^)())success
                         failure:(void (^)(NSError *error))failure;

#pragma mark -
#pragma mark - Logging

- (void)api_logErrorWithDescription:(NSString *)description;

@end
