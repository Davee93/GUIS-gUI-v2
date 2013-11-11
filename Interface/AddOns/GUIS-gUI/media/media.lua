--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local M = LibStub("gMedia-3.0")
assert(M, "Couldn't find an instance of gMedia-3.0")

do
	M:Register("Button", 		"Gloss", 							[[Interface\AddOns\GUIS-gUI\media\texture\Gloss64x64.tga]])
	M:Register("Button", 		"LargeGloss", 						[[Interface\AddOns\GUIS-gUI\media\texture\Gloss256x256.tga]])
	M:Register("Button", 		"Shade", 							[[Interface\AddOns\GUIS-gUI\media\texture\Shade64x64.tga]])
	M:Register("Button", 		"LargeShade", 						[[Interface\AddOns\GUIS-gUI\media\texture\Shade256x256.tga]])
	M:Register("Button", 		"UICloseButton", 					[[Interface\AddOns\GUIS-gUI\media\texture\UICloseButton.tga]])
	M:Register("Button", 		"UICloseButtonDown", 			[[Interface\AddOns\GUIS-gUI\media\texture\UICloseButtonDown.tga]])
	M:Register("Button", 		"UICloseButtonDisabled", 		[[Interface\AddOns\GUIS-gUI\media\texture\UICloseButtonDisabled.tga]])
	M:Register("Button", 		"UICloseButtonHighlight", 		[[Interface\AddOns\GUIS-gUI\media\texture\UICloseButtonHighlight.tga]])

	M:Register("Background", 	"ItemButton", 						[[Interface\AddOns\GUIS-gUI\media\texture\ItemButton.tga]])
	M:Register("Background", 	"MildSatin", 						[[Interface\AddOns\GUIS-gUI\media\texture\MildSatin.tga]])
	M:Register("Background", 	"Satin", 							[[Interface\AddOns\GUIS-gUI\media\texture\MildSatin.tga]])
	M:Register("Background", 	"UnitShader", 						[[Interface\AddOns\GUIS-gUI\media\texture\unitshader.tga]])
	M:Register("Background", 	"VoidStorage", 					[[Interface\AddOns\GUIS-gUI\media\texture\VoidStorage.tga]])

	M:Register("Border", 		"Glow", 								[[Interface\AddOns\GUIS-gUI\media\texture\glowtex.tga]])
	M:Register("Border", 		"PixelBorder", 					[[Interface\AddOns\GUIS-gUI\media\texture\PixelBorder.tga]])
	M:Register("Border", 		"PixelBorderIndented", 			[[Interface\AddOns\GUIS-gUI\media\texture\PixelBorderIndented.tga]])

	M:Register("Font", 			"Big Noodle Titling", 			[[Interface\AddOns\GUIS-gUI\media\fonts\BigNoodleTitling.ttf]])
	M:Register("Font", 			"Matthan Sans NC", 				[[Interface\AddOns\GUIS-gUI\media\fonts\Matthan Sans NC.ttf]])
	M:Register("Font", 			"PT Sans Narrow Bold", 			[[Interface\AddOns\GUIS-gUI\media\fonts\PT Sans Narrow Bold.ttf]])
	M:Register("Font", 			"Righteous Kill Condensed", 	[[Interface\AddOns\GUIS-gUI\media\fonts\RighteousKill-Condensed.ttf]])
	M:Register("Font", 			"TrashHand", 						[[Interface\AddOns\GUIS-gUI\media\fonts\TrashHand.TTF]])
	M:Register("Font", 			"Waukegan LDO", 					[[Interface\AddOns\GUIS-gUI\media\fonts\Waukegan LDO.ttf]])

	M:Register("Icon", 			"ArrowBottom", 					[[Interface\AddOns\GUIS-gUI\media\icons\ArrowBottom32x32.tga]])
	M:Register("Icon", 			"ArrowBottomDisabled", 			[[Interface\AddOns\GUIS-gUI\media\icons\ArrowBottomDisabled32x32.tga]])
	M:Register("Icon", 			"ArrowBottomHighlight", 		[[Interface\AddOns\GUIS-gUI\media\icons\ArrowBottomHighlight32x32.tga]])
	M:Register("Icon", 			"ArrowDown", 						[[Interface\AddOns\GUIS-gUI\media\icons\ArrowDown32x32.tga]])
	M:Register("Icon", 			"ArrowDownDisabled", 			[[Interface\AddOns\GUIS-gUI\media\icons\ArrowDownDisabled32x32.tga]])
	M:Register("Icon", 			"ArrowDownHighlight", 			[[Interface\AddOns\GUIS-gUI\media\icons\ArrowDownHighlight32x32.tga]])
	M:Register("Icon", 			"ArrowFirst", 						[[Interface\AddOns\GUIS-gUI\media\icons\ArrowFirst32x32.tga]])
	M:Register("Icon", 			"ArrowFirstDisabled", 			[[Interface\AddOns\GUIS-gUI\media\icons\ArrowFirstDisabled32x32.tga]])
	M:Register("Icon", 			"ArrowFirstHighlight", 			[[Interface\AddOns\GUIS-gUI\media\icons\ArrowFirstHighlight32x32.tga]])
	M:Register("Icon", 			"ArrowLast", 						[[Interface\AddOns\GUIS-gUI\media\icons\ArrowLast32x32.tga]])
	M:Register("Icon", 			"ArrowLastDisabled", 			[[Interface\AddOns\GUIS-gUI\media\icons\ArrowLastDisabled32x32.tga]])
	M:Register("Icon", 			"ArrowLastHighlight", 			[[Interface\AddOns\GUIS-gUI\media\icons\ArrowLastHighlight32x32.tga]])
	M:Register("Icon", 			"ArrowLeft", 						[[Interface\AddOns\GUIS-gUI\media\icons\ArrowLeft32x32.tga]])
	M:Register("Icon", 			"ArrowLeftDisabled", 			[[Interface\AddOns\GUIS-gUI\media\icons\ArrowLeftDisabled32x32.tga]])
	M:Register("Icon", 			"ArrowLeftHighlight", 			[[Interface\AddOns\GUIS-gUI\media\icons\ArrowLeftHighlight32x32.tga]])
	M:Register("Icon", 			"ArrowRight", 						[[Interface\AddOns\GUIS-gUI\media\icons\ArrowRight32x32.tga]])
	M:Register("Icon", 			"ArrowRightDisabled", 			[[Interface\AddOns\GUIS-gUI\media\icons\ArrowRightDisabled32x32.tga]])
	M:Register("Icon", 			"ArrowRightHighlight", 			[[Interface\AddOns\GUIS-gUI\media\icons\ArrowRightHighlight32x32.tga]])
	M:Register("Icon", 			"ArrowTop", 						[[Interface\AddOns\GUIS-gUI\media\icons\ArrowTop32x32.tga]])
	M:Register("Icon", 			"ArrowTopDisabled", 				[[Interface\AddOns\GUIS-gUI\media\icons\ArrowTopDisabled32x32.tga]])
	M:Register("Icon", 			"ArrowTopHighlight", 			[[Interface\AddOns\GUIS-gUI\media\icons\ArrowTopHighlight32x32.tga]])
	M:Register("Icon", 			"ArrowUp", 							[[Interface\AddOns\GUIS-gUI\media\icons\ArrowUp32x32.tga]])
	M:Register("Icon", 			"ArrowUpDisabled", 				[[Interface\AddOns\GUIS-gUI\media\icons\ArrowUpDisabled32x32.tga]])
	M:Register("Icon", 			"ArrowUpHighlight", 				[[Interface\AddOns\GUIS-gUI\media\icons\ArrowUpHighlight32x32.tga]])
	M:Register("Icon", 			"ArrowLeft64", 					[[Interface\AddOns\GUIS-gUI\media\icons\ArrowLeft.tga]])
	M:Register("Icon", 			"ArrowLeftHighlight64", 		[[Interface\AddOns\GUIS-gUI\media\icons\ArrowLeftHighlight.tga]])
	M:Register("Icon", 			"ArrowRight64", 					[[Interface\AddOns\GUIS-gUI\media\icons\ArrowRight32x32.tga]])
	M:Register("Icon", 			"ArrowRightHighlight64", 		[[Interface\AddOns\GUIS-gUI\media\icons\ArrowRightHighlight.tga]])
	M:Register("Icon", 			"ArrowDown64", 					[[Interface\AddOns\GUIS-gUI\media\icons\ArrowDown.tga]])
	M:Register("Icon", 			"ArrowDownHighlight64", 		[[Interface\AddOns\GUIS-gUI\media\icons\ArrowDownHighlight.tga]])
	M:Register("Icon", 			"ArrowUp64", 						[[Interface\AddOns\GUIS-gUI\media\icons\ArrowUp.tga]])
	M:Register("Icon", 			"ArrowUpHighlight64", 			[[Interface\AddOns\GUIS-gUI\media\icons\ArrowUpHighlight.tga]])
	M:Register("Icon", 			"BagIcon", 							[[Interface\AddOns\GUIS-gUI\media\icons\BagIcon64x64.tga]])
	M:Register("Icon", 			"BagIconDisabled", 				[[Interface\AddOns\GUIS-gUI\media\icons\BagIconDisabled64x64.tga]])
	M:Register("Icon", 			"BagIconHighlight", 				[[Interface\AddOns\GUIS-gUI\media\icons\BagIconHighlight64x64.tga]])
	M:Register("Icon", 			"BagRestack", 						[[Interface\AddOns\GUIS-gUI\media\icons\BagRestackIcon128x64.tga]])
	M:Register("Icon", 			"BagRestackDisabled", 			[[Interface\AddOns\GUIS-gUI\media\icons\BagRestackIconDisabled128x64.tga]])
	M:Register("Icon", 			"BagRestackHighlight", 			[[Interface\AddOns\GUIS-gUI\media\icons\BagRestackIconHighlight128x64.tga]])
	M:Register("Icon", 			"BagRestackPushed", 				[[Interface\AddOns\GUIS-gUI\media\icons\BagRestackIconPushed128x64.tga]])
	M:Register("Icon", 			"Bubble", 							[[Interface\AddOns\GUIS-gUI\media\texture\bubbleTex.tga]])
	M:Register("Icon", 			"Calendar", 						[[Interface\AddOns\GUIS-gUI\media\icons\Calendar_32x32.tga]])
	M:Register("Icon", 			"Cog", 								[[Interface\AddOns\GUIS-gUI\media\icons\Cog32x32.tga]])
	M:Register("Icon", 			"GridIndicator", 					[[Interface\AddOns\GUIS-gUI\media\icons\GridIndicatorSquare16x16.tga]])
	M:Register("Icon", 			"MailBox", 							[[Interface\AddOns\GUIS-gUI\media\icons\Mailbox2-32x32.tga]])
	M:Register("Icon", 			"Refresh", 							[[Interface\AddOns\GUIS-gUI\media\icons\refresh.tga]])
	M:Register("Icon", 			"Stopsign", 						[[Interface\AddOns\GUIS-gUI\media\icons\stopsign.tga]])

	M:Register("StatusBar", 	"ProgressBar", 					[[Interface\AddOns\GUIS-gUI\media\texture\progressbar.tga]])
	M:Register("StatusBar", 	"StatusBar", 						[[Interface\AddOns\GUIS-gUI\media\texture\StatusBar.tga]])

	M:Register("Texture", 		"BigTimerNumbers", 				[[Interface\AddOns\GUIS-gUI\media\texture\BigTimerNumbers.tga]])
	M:Register("Texture", 		"BigTimerNumbersGlow", 			[[Interface\AddOns\GUIS-gUI\media\texture\BigTimerNumbersGlow.tga]])
	M:Register("Texture", 		"BigTimerNumbersWhite", 		[[Interface\AddOns\GUIS-gUI\media\texture\BigTimerNumbersWhite.tga]])

	-- social sharing buttons
	M:Register("Icon", 			"Facebook", 						[[Interface\AddOns\GUIS-gUI\media\icons\facebook_icon_16.tga]])
	M:Register("Icon", 			"Twitter", 							[[Interface\AddOns\GUIS-gUI\media\icons\twitter_icon_16.tga]])
	M:Register("Icon", 			"YouTube", 							[[Interface\AddOns\GUIS-gUI\media\icons\youtube_icon_16.tga]])

	-- gUI logo
	M:Register("Texture", 		"gUILogo", 							[[Interface\AddOns\GUIS-gUI\media\texture\gUI512x256.tga]])
	
	-- Horde and Alliance logos and stuff
	M:Register("Icon", 			"FactionAlliance32", 			[[Interface\AddOns\GUIS-gUI\media\icons\Alliance_32.tga]])
	M:Register("Icon", 			"FactionHorde32", 				[[Interface\AddOns\GUIS-gUI\media\icons\Horde_32.tga]])
	M:Register("Texture", 		"FactionAllianceCrest", 		[[Interface\AddOns\GUIS-gUI\media\texture\260x284-AllianceCrest.tga]])
	M:Register("Texture", 		"FactionHordeCrest", 			[[Interface\AddOns\GUIS-gUI\media\texture\260x320-Horde_Crest.tga]])
	
	-- emoticons
	M:Register("Icon", 			"Emoticon-Angel", 				[[Interface\AddOns\GUIS-gUI\media\icons\emoticon-angel.tga]])
	M:Register("Icon", 			"Emoticon-Confused", 			[[Interface\AddOns\GUIS-gUI\media\icons\emoticon-confused.tga]])
	M:Register("Icon", 			"Emoticon-Cry", 					[[Interface\AddOns\GUIS-gUI\media\icons\emoticon-cry.tga]])
	M:Register("Icon", 			"Emoticon-Devil", 				[[Interface\AddOns\GUIS-gUI\media\icons\emoticon-devil.tga]])
	M:Register("Icon", 			"Emoticon-Frown", 				[[Interface\AddOns\GUIS-gUI\media\icons\emoticon-frown.tga]])
	M:Register("Icon", 			"Emoticon-Gasp", 					[[Interface\AddOns\GUIS-gUI\media\icons\emoticon-gasp.tga]])
	M:Register("Icon", 			"Emoticon-Glasses", 				[[Interface\AddOns\GUIS-gUI\media\icons\emoticon-glasses.tga]])
	M:Register("Icon", 			"Emoticon-Grin", 					[[Interface\AddOns\GUIS-gUI\media\icons\emoticon-grin.tga]])
	M:Register("Icon", 			"Emoticon-Grumpy", 				[[Interface\AddOns\GUIS-gUI\media\icons\emoticon-grumpy.tga]])
	M:Register("Icon", 			"Emoticon-Heart", 				[[Interface\AddOns\GUIS-gUI\media\icons\emoticon-heart.tga]])
	M:Register("Icon", 			"Emoticon-Kiki", 					[[Interface\AddOns\GUIS-gUI\media\icons\emoticon-kiki.tga]])
	M:Register("Icon", 			"Emoticon-Kiss", 					[[Interface\AddOns\GUIS-gUI\media\icons\emoticon-kiss.tga]])
	M:Register("Icon", 			"Emoticon-Smile", 				[[Interface\AddOns\GUIS-gUI\media\icons\emoticon-smile.tga]])
	M:Register("Icon", 			"Emoticon-Squint", 				[[Interface\AddOns\GUIS-gUI\media\icons\emoticon-squint.tga]])
	M:Register("Icon", 			"Emoticon-Sunglasses", 			[[Interface\AddOns\GUIS-gUI\media\icons\emoticon-sunglasses.tga]])
	M:Register("Icon", 			"Emoticon-Tongue", 				[[Interface\AddOns\GUIS-gUI\media\icons\emoticon-tongue.tga]])
	M:Register("Icon", 			"Emoticon-Unsure", 				[[Interface\AddOns\GUIS-gUI\media\icons\emoticon-unsure.tga]])
	M:Register("Icon", 			"Emoticon-Upset", 				[[Interface\AddOns\GUIS-gUI\media\icons\emoticon-upset.tga]])
	M:Register("Icon", 			"Emoticon-Wink", 					[[Interface\AddOns\GUIS-gUI\media\icons\emoticon-wink.tga]])

	-- Hankthetank's raid target icons (http://www.wowinterface.com/downloads/info16243-Raidicons.html)
	M:Register("Icon", 			"RaidTarget", 						[[Interface\AddOns\GUIS-gUI\media\icons\UI-RaidTargetingIcons.blp]])
	
	-- sounds
	M:Register("Sound", 			"Whisper", 							[[Interface\AddOns\GUIS-gUI\media\sound\whisper.mp3]])
	
	-- screenshots and stuff for the FAQ module
	M:Register("Texture", 		"Actionbars-SideArrow", 		[[Interface\AddOns\GUIS-gUI\media\faq\actionbar-side-arrow.tga]])
	M:Register("Texture", 		"Bags-QuickMenu", 				[[Interface\AddOns\GUIS-gUI\media\faq\bag-category-quickmenu.tga]])
	M:Register("Texture", 		"Core-FrameLock", 				[[Interface\AddOns\GUIS-gUI\media\faq\core-glock-movement.tga]])
	M:Register("Texture", 		"Core-ModuleMenu", 				[[Interface\AddOns\GUIS-gUI\media\faq\core-module-selection.tga]])
	M:Register("Texture", 		"Minimap-Calendar", 				[[Interface\AddOns\GUIS-gUI\media\faq\minimap-calendar-menu.tga]])

	
	M:Register("Backdrop", "StatusBar", {
		bgFile = M["StatusBar"]["StatusBar"];
		insets = { 
			bottom = 0; 
			left = 0; 
			right = 0; 
			top = 0; 
		};
	})
	
	M:Register("Backdrop", "StatusBarBorder", {
		bgFile = M["StatusBar"]["StatusBar"];
		edgeFile = M["Border"]["PixelBorder"]; 
		edgeSize = 8;
		insets = { 
			bottom = 2; 
			left = 2; 
			right = 2; 
			top = 2; 
		};
	})

	M:Register("Backdrop", "Glow", {
		edgeFile = M["Border"]["Glow"];
		edgeSize = 3;
		insets = { 
			bottom = 0; 
			left = 0; 
			right = 0; 
			top = 0; 
		};
	})

	M:Register("Backdrop", "PixelBorder", {
		edgeFile = M["Border"]["PixelBorder"]; 
		edgeSize = 8;
		insets = { 
			bottom = 0; 
			left = 0; 
			right = 0; 
			top = 0; 
		};
	})

	M:Register("Backdrop", "PixelBorder-Satin", {
		bgFile = M["Background"]["MildSatin"]; 
		edgeFile = M["Border"]["PixelBorder"]; 
		edgeSize = 8;
		insets = { 
			bottom = 2; 
			left = 2; 
			right = 2; 
			top = 2; 
		};
	})

	-- applying the bag solution to fake padding
	M:Register("Backdrop", "PixelBorderIndented-Satin", {
		bgFile = M["Background"]["MildSatin"]; 
		edgeFile = M["Border"]["PixelBorderIndented"]; 
		edgeSize = 8;
		insets = { 
			bottom = 4; 
			left = 4; 
			right = 4; 
			top = 4; 
		};
	})

	M:Register("Backdrop", "PixelBorder-Blank", {
		bgFile = M["Background"]["Blank"]; 
		edgeFile = M["Border"]["PixelBorder"]; 
		edgeSize = 8;
		insets = { 
			bottom = 2; 
			left = 2; 
			right = 2; 
			top = 2; 
		};
	})

	M:Register("Backdrop", "ItemButton", {
		bgFile = M["Background"]["ItemButton"]; 
		edgeFile = M["Border"]["PixelBorder"]; 
		edgeSize = 8;
		insets = { 
			bottom = 2; 
			left = 2; 
			right = 2; 
			top = 2; 
		};
	})

	M:Register("Backdrop", "TargetBorder", {
		bgFile = nil; 
		edgeFile = M["Background"]["Blank"]; 
		edgeSize = 2;
		insets = { 
			bottom = 0; 
			left = 0; 
			right = 0; 
			top = 0; 
		};
	})
	
	M:Register("Backdrop", "HighlightBorder", {
		bgFile = M["Background"]["Blank"]; 
		edgeFile = M["Background"]["Blank"]; 
		edgeSize = 2;
		insets = { 
			bottom = 0; 
			left = 0; 
			right = 0; 
			top = 0; 
		};
	})

	M:Register("Backdrop", "ThinBorder", {
		bgFile = M["Background"]["Blank"]; 
		insets = { 
			bottom = -1; 
			left = -1; 
			right = -1; 
			top = -1; 
		};
	})
end
