//
//  OHTableView.m
//  OpenHUD
//
//  Created by Jeff Ganyard on 4/15/06.
//

#import "OHTableView.h"
#import "OHTableHeaderCell.h"
#import "OHCornerView.h"
#import "OHConstants.h"
#import "OHWindow.h"


@implementation OHTableView

- (void)awakeFromNib
{
	[self setGridColor:[NSColor lightGrayColor]];
	[self setBackgroundColor:nil];
	[(NSClipView *)[self opaqueAncestor] setDrawsBackground:NO];
	[(NSScrollView *)[[self superview] superview] setBorderType:NSNoBorder]; // ugly but it will have to do until OHScrollView is done
	
//	NSFont *defaultFont = [NSFont systemFontOfSize:[NSFont smallSystemFontSize]];
//	NSFont *defaultFont = [NSFont systemFontOfSize:10.0];
//	[self setRowHeight:[defaultFont defaultLineHeightForFont]+2];

	/* portions based on Matt Gemmel's iTableColumnHeader */
	NSArray *tableColumns = [self tableColumns];
	NSEnumerator *columns = [tableColumns objectEnumerator];
	NSTableColumn *column = nil;
	OHTableHeaderCell *ohHeaderCell;
	while (column = [columns nextObject]) {
//		[[column dataCell] setFont:defaultFont];
		
		if([[column dataCell] isKindOfClass:[NSTextFieldCell class]]){
			[[column dataCell] setTextColor:[NSColor whiteColor]];
		}
//		NSLog(@"head align: %@", [[column headerCell] alignment]);
		ohHeaderCell = [[OHTableHeaderCell alloc] initTextCell:[[column headerCell] stringValue]];
		[column setHeaderCell:ohHeaderCell];
		[ohHeaderCell release];
	}
	OHCornerView *ohCorner = [[[OHCornerView alloc] init] autorelease];
	[self setCornerView:ohCorner];
}

/* private method */
- (id)_highlightColorForCell:(NSCell *)cell;
{
	return nil;
}

- (NSColor *)backgroundColor
{
	switch (/*HUDStyle()*/OHProStyle)
	{
		case OHIAppStyle:
			return [NSColor colorWithCalibratedWhite:0.1 alpha:0.75];
		case OHProStyle:
			return [NSColor colorWithCalibratedRed:0.12549 green:0.12549 blue:0.12549 alpha:0.95];
		default:
			return nil;
	}
}

- (void)drawRow:(int)row clipRect:(NSRect)clipRect {
	NSColor *rowColor;
	NSRect rect = [self rectOfRow:row];
	float offsetW, offsetH;
	if ([[self selectedRowIndexes] containsIndex:row] && ([self editedRow] != row)) {
		rowColor = [NSColor colorWithCalibratedWhite:.8	alpha:.75];
		offsetH = 1.0;
		offsetW = 4.0;
	}
	else {
		if (row % 2 == 0)
			rowColor = [[self backgroundColor] blendedColorWithFraction:0.2 ofColor:[NSColor blackColor]];
		else
			rowColor = [[self backgroundColor] blendedColorWithFraction:0.5 ofColor:[NSColor blackColor]];
		offsetH = 1.0;
		offsetW = 4.0;
	}
	[rowColor set];

	NSBezierPath *path = [NSBezierPath bezierPath];
	[path setLineCapStyle:NSSquareLineCapStyle];
	[path setLineWidth:rect.size.height-offsetH];
	//        int rowLevel = [self levelForRow:row];  // outlineview stuff not needed for tableview
	float x = rect.origin.x + 8;  // + (rowLevel * [self indentationPerLevel]);
	float y = rect.origin.y + (rect.size.height / 2.0);
	[path moveToPoint:NSMakePoint(x,y)];
	[path lineToPoint:NSMakePoint(x + rect.size.width - 2*10.0 + offsetW, y)];
	[path stroke];
	
	[super drawRow:row clipRect:clipRect];
}

- (BOOL)isOpaque 
{
	return NO;
}

@end
