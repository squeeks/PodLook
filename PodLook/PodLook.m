#import <Foundation/Foundation.h>
#import "PodLook.h"

NSMutableString *PodHtmlConversion(char const *PODFile)
{
	
	NSString *FileLocation = [[[NSString alloc] initWithUTF8String:PODFile] autorelease];	
	
	NSTask *Pod2HTMLTask;
	Pod2HTMLTask = [[NSTask alloc] init];
	[Pod2HTMLTask setLaunchPath: @"/usr/bin/pod2html"];
	
	[Pod2HTMLTask setArguments: [NSArray arrayWithObjects: @" --title=\"\"", FileLocation, nil]];
	
	NSPipe *pipe = [[NSPipe alloc] init];
	[Pod2HTMLTask setStandardOutput: pipe];

	NSFileHandle *file;
	file = [pipe fileHandleForReading];
	
	[Pod2HTMLTask launch];
	[Pod2HTMLTask waitUntilExit];
	
	NSData *data;
	data = [file readDataToEndOfFile];
	
	// Release the pipe and task
	[pipe release];
	[Pod2HTMLTask release];

	NSMutableString *html = [[[NSMutableString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];

	if( [html length] > 650 )
	{
		// Sneak our CSS in
		char const *css =	"<div id=\"nav\"><h1><a href=\"#__index__\">Documentation</a></h1>"
							"<h1><a href=\"#source\">Source</a></h1></div>"
							"<style>"		
							"hr{border:0;}"
							"body{margin-top:30px}"
							"h1{font-size:large;}"
							"#nav h1 a, a, li a{color:#069;}"
							"#nav h1{display:inline;margin:0 0 0 1em;}"
							"h2,h3,h4,h5,h6{font-size:medium;}"
							"p{font:10pt Helvetica,sans-serif;}"
							"code{background-color:#eee;}"
							"ul{list-style-type:none;margin:0;}"
							"a{text-decoration:none;}"
							"li a{font:10pt Helvetica,sans-serif;}"
							"pre{background:none repeat scroll 0 0 #eee;padding:1em;"
							"border:1px solid #888;color:#000;white-space:pre;}"
							"#source_code{border-top:3px solid #069;}"
							"#source_code pre{background-color:#eee;border:none;font:8pt Monaco;}"
							"h1 a,h2 a, h3 a, h4 a, h5 a, h6 a{color:#069;font-size:90%;}"
							"#nav{left:0;position:absolute;border-bottom:1px solid #069;"
							"position:fixed;background-color:#ddd;width:100%;z-index:1;top:0;}"
							"h1,h2,h3,h4,h5,h6{font-family:Helvetica,sans-serif;margin-bottom:0;}"
							"</style>"
							"<div id=\"source_code\">"
							"<h1><a name=\"source\">Source:</a></h1>";

		NSMutableString *stylesheet = [[[NSMutableString alloc] initWithUTF8String: css] autorelease];
		[html appendString:stylesheet];
		
		//Append the source code to the bottom
		const char *sourceHeader = "<pre>";
		const char *sourceFooter = "</pre></div>";
		NSMutableString *sourceOutput = [[[NSMutableString alloc] initWithCString: sourceHeader] autorelease];
		NSMutableString *sourceCode   = [[[NSMutableString alloc] initWithContentsOfFile: FileLocation] autorelease];
		
		// Clean out characters that break
		[sourceCode replaceOccurrencesOfString:@"&" withString:@"&amp;" options:0 range:NSMakeRange(0, [sourceCode length])];
		[sourceCode replaceOccurrencesOfString:@">" withString:@"&gt;"  options:0 range:NSMakeRange(0,  [sourceCode length])];
		[sourceCode replaceOccurrencesOfString:@"<" withString:@"&lt;"  options:0 range:NSMakeRange(0,  [sourceCode length])];
		
		NSMutableString *sourceEnd    = [[[NSMutableString alloc] initWithCString: sourceFooter] autorelease];
		
		[sourceOutput appendString: sourceCode];
		[sourceOutput appendString: sourceEnd];
		
		[html appendString:sourceOutput];

		return html;

	}
	else
	{

		// Wrap the code in some fixed width fontiness
		const char *sourceHeader = "<pre style=\"font:8pt Monaco\">";
		const char *sourceFooter = "</pre>";
		NSMutableString *sourceOutput = [[[NSMutableString alloc] initWithCString: sourceHeader] autorelease];
		NSMutableString *sourceCode   = [[[NSMutableString alloc] initWithContentsOfFile: FileLocation] autorelease];
		NSMutableString *sourceEnd    = [[[NSMutableString alloc] initWithCString: sourceFooter] autorelease];

		[sourceOutput appendString: sourceCode];
		[sourceOutput appendString: sourceEnd];

		return sourceOutput;

	}

}