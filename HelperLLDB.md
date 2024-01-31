LLDB helpers 

// let $object = unsafeBitCast(0x28247ead0, to: AnyObject.self)

ptr_refs -z -r
malloc_info -z -r 

expression -l swift -- import UIKit

expression -l swift -- let $object = UnsafeMutablePointer<AnyObject>(bitPattern: <address>)?.pointee
expression -l swift -- unsafeBitCast(<address>, to: AnyObject.self)
expression -l swift -- UnsafeMutablePointer<Int>(bitPattern: <address>)?.deallocate()

expression -l swift -- malloc_size(UnsafeMutableRawPointer(bitPattern: <address>))


po [(id)<address> retainCount] - count of reference for class 
expression -l objc -O -- [(id)0x10664f610 release]

Best deallocation

expression (void)vm_deallocate(mach_task_self_, 0x1712b0000, 0x17313c000-0x1712b0000)
expression -l swift -- UnsafeMutablePointer<Int>(bitPattern: <address>)?.deallocate()

expression -l swift -- vm_address_t(truncatingIfNeeded: Int(bitPattern: ))

UnsafeBufferPointer
