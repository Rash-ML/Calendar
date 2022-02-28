import Foundation

infix operator ..
/// Takes left argument and applies right closure on it.
/// - Parameters:
///   - lhs: The argument to edit
///   - rhs: The closure to perform on the left argument
/// - Returns: Edited left argument
func ..<T: AnyObject>(_ lhs: T, _ rhs: (T)->()) -> T { rhs(lhs); return lhs }
