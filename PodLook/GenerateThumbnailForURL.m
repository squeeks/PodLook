#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#include <WebKit/WebKit.h>
#include <AppKit/AppKit.h>
#include <PodLook.h>

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	NSMutableString *html = PodHtmlConversion([[(NSURL*)url path] fileSystemRepresentation]);
	
	NSRect webKitRect = NSMakeRect(0.0, 0.0, 600.0, 800.0);
	CGSize thumbSize = NSSizeToCGSize(NSMakeSize(maxSize.width * (600.0/800.0),
												 maxSize.height));
	float scale = maxSize.height / 800.0;
	NSSize scaleSize = NSMakeSize(scale, scale);
	
	WebView* webView = [[WebView alloc] initWithFrame:webKitRect];
	[webView scaleUnitSquareToSize:scaleSize];
	[[[webView mainFrame] frameView] setAllowsScrolling:NO];
	
	[[webView mainFrame] loadData:[html dataUsingEncoding:NSUTF8StringEncoding]
						 MIMEType:@"text/html"
				 textEncodingName:@"UTF-8" baseURL:nil];
	
	while([webView isLoading]) {
		CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true);
	}
	
	CGContextRef cgContext = 
    QLThumbnailRequestCreateContext(thumbnail, thumbSize, false, NULL);
	NSGraphicsContext* context = 
    [NSGraphicsContext graphicsContextWithGraphicsPort:(void *)cgContext 
											   flipped:[webView isFlipped]];
	
	[webView displayRectIgnoringOpacity:[webView bounds] inContext:context];
    
	QLThumbnailRequestFlushContext(thumbnail, cgContext);
	
	CFRelease(cgContext);
	
	[pool release];	
    return noErr;
}

void CancelThumbnailGeneration(void* thisInterface, QLThumbnailRequestRef thumbnail)
{
    // implement only if supported
}
