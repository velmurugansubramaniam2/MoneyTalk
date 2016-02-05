//
//  TCSMTAnalytics.h
//  MT
//
//  Created by spb-PBaranov on 08/05/15.
//  Copyright (c) 2015 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCSMTAnalytics : NSObject

+ (instancetype)sharedInstance;

- (void)setupWithLaunchOptions:(NSDictionary*)launchOptions;
- (void)logEvent:(NSString*)event withParams:(NSDictionary*)params;

@end


#pragma mark Analytics Events

//MT 1.0 Общие события 1.0
/*static NSString *const TCSMTEventLaunch = @"Launch";
static NSString *const TCSMTEventPreloaderStart = @"PreloaderStart"; // ??? not found

//MT 1.1 Авторизация/Регистрация 1.0
static NSString *const TCSMTEventLoginSuccess = @"Login.Success";
static NSString *const TCSMTEventLoginContinue = @"Login.Continue";
static NSString *const TCSMTEventLoginAddCard = @"Login.ChatOfList.AddCard";

//MT 1.2 Ввод кода доступа 1.0
static NSString *const TCSMTEventChangePasscodeFromSettings = @"LaunchOfPasscode.FromDiscard";
static NSString *const TCSMTEventPasscodeLoginSuccess = @"LoginToPasscode.Success";
static NSString *const TCSMTEventLoginToTouchID = @"LoginToTouchID.Success";

//MT 1.3 Регистрация по иностранному номеру телефона. Выбор страны. 1.0
static NSString *const TCSMTEventEnterCountrySelect = @"Country";


//MT 2.1 Список чатов 1.0
static NSString *const TCSMTEventEnterSettings = @"ListOfChats.Setting";
static NSString *const TCSMTEventEnterNewConversation = @"ListOfChats.NewMessage";

//MT 4.1 Чат 1.0
static NSString *const TCSMTEventOpenChat =  @"ListOfChats.OpenChat";
static NSString *const TCSMTEventOpenGroupChat = @"ListOfChats.OpenGroupChat";

static NSString *const TCSMTEventMessageSending = @"Сhat.SendingOfMessage";
static NSString *const TCSMTEventMoneySendSuccess = @"Сhat.SendingOfMoney.Success";
static NSString *const TCSMTEventRoublitizationButtonPress = @"Chat.RubButton.Money";
static NSString *const TCSMTEventRemoveConversationSuccess = @"Chat.DeleteChat.Success";
static NSString *const TCSMTEventCancelSendingOfMoney = @"Сhat.SendingOfMoney.Cancel";
static NSString *const TCSMTEventConfirmationError = @"Сhat.SendingOfMoney.Error";
static NSString *const TCSMTEventSendCoffeeSuccess = @"Chat.SendCoffee.Success";

static NSString *const TCSMTEventEasterEggOpen = @"Chat.RubButton.EasterEggs";
static NSString *const TCSMTEventEasterEggCancel = @"EasterEggs.Cancel";
static NSString *const TCSMTEventEasterEggSend = @"EasterEggs.Send";

//MT 4.1.1.2 Настройки группового чата 1.0
static NSString *const TCSMTEventGroupChatSettingsOpen = @"GroupChat.Settings";
static NSString *const TCSMTEventGroupChatNewUserAdded = @"GroupChat.NewUser";
static NSString *const TCSMTEventGroupChatLeaved = @"GroupChat.Out";
static NSString *const TCSMTEventGroupChatSettingsSaved = @"GroupChat.SafeSetting";
static NSString *const TCSMTEventGroupChatSettingsCanceled = @"GroupChat.Cancel";

//MT 4.2 Выбор получателя. Экран новое сообщение 1.0
static NSString *const TCSMTEventSelectNonClientRecipient = @"Chat.ChoiceToNonUserChat";
static NSString *const TCSMTEventSelectRecipient = @"Chat.ChoiceRecipient";
static NSString *const TCSMTEventNewContactAdded = @"Chat.AddNewContact";
static NSString *const TCSMTEventEnterGroupChatCreating = @"Chat.CreateGroup";
static NSString *const TCSMTEventGroupChatCreated = @"Chat.CreateGroup.Success";


//MT 5.1 Настройки 1.0
static NSString *const TCSMTEventPushNotificationsTurnOn = @"Setting.Push.SwitchOn";
static NSString *const TCSMTEventPushNotificationsTurnOff = @"Setting.Push.SwitchOff";
static NSString *const TCSMTEventEnterReset = @"Setting.Discard";
static NSString *const TCSMTEventEnterSoundSettings = @"Setting.Sounds";
static NSString *const TCSMTEventEnterHelp = @"Setting.Help";
static NSString *const TCSMTEventEnterSendFeedback = @"Setting.SendMessage";
static NSString *const TCSMTEventEnterAbout = @"Setting.About";

//MT 5.2 Список контактов 1.0
static NSString *const TCSMTEventMoveToSettingsFromContacts = @"ListOfContacts.MobileSettings";

//MT 5.3 Добавить карту 1.0
static NSString *const TCSMTEventAddCardEnterScanIO = @"AddCard.StartCardNumberCardIOScanning";
static NSString *const TCSMTEventAddCardCancelScanIO = @"AddCard.CancelCardNumberCardIOScanning";
static NSString *const TCSMTEventAddCardScanIOSuccess = @"AddCard.ScanCardNumberCardIO.Success";
static NSString *const TCSMTEventAddCardValidationSuccess = @"AddCard.ValidCardNumberEntered";
static NSString *const TCSMTEventAddCard = @"AddCard.Ready";
static NSString *const TCSMTEventAddCardSuccess = @"AddCard.Ready.Added";
static NSString *const TCSMTEventAddCardCancelButtonPress = @"AddCard.Cancel";
static NSString *const TCSMTEventChatAddCardOnSendButtonPress = @"Chat.AddCard.ToSend";
static NSString *const TCSMTEventChatAddCardOnReceiveButtonPress = @"Chat.AddCard.Receive";
static NSString *const TCSMTEventYourCardsEnterAddCard = @"YourCards.AddNewCard";

//MT 5.4 Сохраненные карты 1.0
static NSString *const TCSMTEventYourCardsRemoveCardSuccess = @"YourCards.DeleteSuccess";

//MT 5.5 Звуки
static NSString *const TCSMTEventSoundSettingsIncomingMessagesOff = @"Sounds.ToMessage.Off";
static NSString *const TCSMTEventSoundSettingsOutgoingMessagesOff = @"Sounds.SendMessage.Off";
static NSString *const TCSMTEventSoundSettingsIncomingTransactionOff = @"Sounds.ToMoney.Off";
static NSString *const TCSMTEventSoundSettingsOutgoingTransactionOff = @"Sounds.SendMoney.Off";

//MT 5.5.1 О программе
static NSString *const TCSMTEventAboutEnterEula = @"About.Eula";
static NSString *const TCSMTEventAboutEnterTransfersAgreement = @"About.Transfers";

//MT 5.5.2 Отправить сообщение
static NSString *const TCSMTEventSendFeedbackTopicSelected = @"Feedback.ThemeSelected";
static NSString *const TCSMTEventSendFeedbackEmailEntered = @"Feedback.EmailTyped";
static NSString *const TCSMTEventSendFeedbackMessageEntered = @"Feedback.MessageTyped";
static NSString *const TCSMTEventSendFeedbackSuccess = @"Feedback.SendMessage";

//MT 5.6 Сброс 1.0
static NSString *const TCSMTEventResetChangeUser = @"Discard.ChangeUser";
static NSString *const TCSMTEventResetAll = @"Discard.DiscardAll";
static NSString *const TCSMTEventResetDeleteAccount = @"Discard.DeleteAccount"; //??? not found

//MT 5.7 Оценить приложение
static NSString *const TCSMTEventRateButtonNoClick = @"RateApplication.RateButtonNo";
static NSString *const TCSMTEventLikeButtonClick = @"RateApplication.LikeButtonClick";
static NSString *const TCSMTEventUnlikeButtonClick = @"RateApplication.UnlikeButtonClick";
static NSString *const TCSMTEventSendFeedbackClick = @"RateApplication.SendFeedback.Success";*/
