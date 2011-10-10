#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#include <PodLook.h>

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
	if (QLPreviewRequestIsCancelled(preview))
		return noErr;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *html = PodHtmlConversion([[(NSURL*)url path] fileSystemRepresentation]);
	
	if (!html || [html isEqualToString:@""]) {
        [pool release];
        return noErr;
    }
	
	CFDictionaryRef properties = 
	(CFDictionaryRef)[NSDictionary dictionaryWithObject:@"UTF-8" forKey:(NSString *)kQLPreviewPropertyTextEncodingNameKey];
	
	QLPreviewRequestSetDataRepresentation(preview, 
         (CFDataRef)[html dataUsingEncoding:NSUTF8StringEncoding], 
          kUTTypeHTML, 
          properties);
    
    [pool release];
    return noErr;
}

void CancelPreviewGeneration(void* thisInterface, QLPreviewRequestRef preview)
{
    // implement only if supported
}
