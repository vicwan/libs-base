/* A demonstration of writing and reading with NSArchiver */

#if 1

#include <Foundation/NSArchiver.h>
#include <Foundation/NSString.h>
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSSet.h>
#include <Foundation/NSUtilities.h>

int main()
{
  id set;
  id arp;
  
  arp = [[NSAutoreleasePool alloc] init];

  /* Create a Set of int's */
  set = [[NSSet alloc] initWithObjects:
	  @"apple", @"banana", @"carrot", @"dal", @"escarole", @"fava", nil];

  /* Display the set */
  printf("Writing:\n");
  {
    id o, e = [set objectEnumerator];
    while ((o = [e nextObject]))
      printf("%@\n", o);    
  }

  /* Write it to a file */
  [NSArchiver archiveRootObject: set toFile: @"./nsarchiver.dat"];

  /* Release the object that was coded */
  [set release];

  /* Read it back in from the file */
#if 1
  {
    id d = [[NSData alloc] initWithContentsOfFile:@"./nsarchiver.dat"];
    id a = [NSUnarchiver alloc];
    a = [a initForReadingWithData:d];
    set = [a decodeObject];
  }
#else
  set = [NSUnarchiver unarchiveObjectWithFile: @"./nsarchiver.dat"];
#endif

  /* Display what we read, to make sure it matches what we wrote */
  printf("\nReading:\n");
  {
    id o, e = [set objectEnumerator];
    while ((o = [e nextObject]))
      printf("%@\n", o);    
  }

  /* Do the autorelease. */
  [arp release];
  
  exit(0);
}

#else

#include <gnustep/base/all.h>
#include <Foundation/NSArchiver.h>
#include <Foundation/NSAutoreleasePool.h>

@interface TestClass : NSObject
{
  id next_responder;
}

- (void)setNextResponder: anObject;
- nextResponder;
@end

@implementation TestClass

- (void)setNextResponder: anObject
{
  next_responder = anObject;
}

- nextResponder
{
  return next_responder;
}

// NSCoding protocol
- (void)encodeWithCoder:aCoder
{
  [super encodeWithCoder:aCoder];
  [aCoder encodeObjectReference:next_responder withName:@"Next Responder"];
}

- initWithCoder:aDecoder
{
  id d;
  [super initWithCoder:aDecoder];
  [aDecoder decodeObjectAt:&next_responder withName:&d];
  return self;
}
@end

////////////////////////////////////////

int main()
{
  id arp;
  id r1, r2;

  arp = [[NSAutoreleasePool alloc] init];

  // Create a simple loop
  r1 = [[TestClass alloc] init];
  r2 = [[TestClass alloc] init];
  [r1 setNextResponder: r2];
  [r2 setNextResponder: r1];

  printf("Writing\n");
  printf("%d\n", [r1 hash]);
  printf("%d\n", [r2 hash]);
  printf("%d\n", [[r1 nextResponder] hash]);
  printf("%d\n", [[r2 nextResponder] hash]);

  /* Write it to a file */
  {
    id d = [[NSMutableData alloc] init];
    id a = [[Archiver alloc] initForWritingWithMutableData: d];

    [a startEncodingInterconnectedObjects];
    [a encodeObject: r1 withName:@"one"];
    [a encodeObject: r2 withName:@"another"];
    [a finishEncodingInterconnectedObjects];

    [d writeToFile: @"./nsarchiver.dat" atomically:NO];

    [d release];
    [a release];
  }

  /* Release the object that was coded */
  [r1 release];
  [r2 release];

  /* Read it back in from the file */
  printf("\nReading:\n");
  {
    id d;
    id a = [Unarchiver newReadingFromFile:@"./nsarchiver.dat"];

    [a startDecodingInterconnectedObjects];
    [a decodeObjectAt: &r1 withName:&d];
    [a decodeObjectAt: &r2 withName:&d];
    [a finishDecodingInterconnectedObjects];
  }

  /* Display what we read, to make sure it matches what we wrote */
  {
    printf("%d\n", [r1 hash]);
    printf("%d\n", [r2 hash]);
    printf("%d\n", [[r1 nextResponder] hash]);
    printf("%d\n", [[r2 nextResponder] hash]);
  }

  /* Do the autorelease. */
  [arp release];

  exit(0);
}

#endif
