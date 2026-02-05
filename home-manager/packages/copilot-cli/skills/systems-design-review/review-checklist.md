# Systems Design Review Checklist

This checklist provides detailed review points for low-level C++ and Rust systems code.

## 1. Memory Management

### Ownership Model

**Rust:**
- [ ] Is ownership clear for all data structures?
- [ ] Are lifetimes explicitly annotated where needed?
- [ ] Are borrows minimized and scoped appropriately?
- [ ] Is unnecessary cloning avoided?
- [ ] Are reference cycles prevented or using Weak pointers?
- [ ] Is interior mutability (Cell/RefCell) justified?
- [ ] Are Rc/Arc only used when truly needed?

**C++:**
- [ ] Are resources managed via RAII?
- [ ] Is ownership expressed through smart pointers?
- [ ] Are unique_ptr used for exclusive ownership?
- [ ] Are shared_ptr used only when necessary?
- [ ] Is std::move used to transfer ownership?
- [ ] Are raw pointers only used for non-owning references?
- [ ] Are custom deleters appropriate?

### Resource Management

- [ ] Are all resources acquired in constructors or initialization?
- [ ] Are all resources released in destructors or Drop?
- [ ] Is the Rule of Five (C++) or Drop (Rust) correctly implemented?
- [ ] Are there any resource leaks on error paths?
- [ ] Is exception/panic safety maintained?
- [ ] Are resources cleaned up in correct order?
- [ ] Are circular references between resources avoided?

### Memory Layout

- [ ] Are data structures cache-friendly (sequential access)?
- [ ] Is alignment considered and correct?
- [ ] Is padding minimized where appropriate?
- [ ] Are hot and cold data separated?
- [ ] Is struct layout deterministic (repr(C) in Rust)?
- [ ] Are cache line sizes considered?
- [ ] Is false sharing avoided in concurrent code?

### Allocation Strategy

- [ ] Are allocations in hot paths identified?
- [ ] Can allocations be eliminated or reduced?
- [ ] Are allocations batched or pooled?
- [ ] Is a custom allocator justified?
- [ ] Are allocation failures handled?
- [ ] Is memory fragmentation a concern?
- [ ] Are small allocations grouped?

## 2. Concurrency & Synchronization

### Threading Model

- [ ] Is the threading model clearly documented?
- [ ] Are thread responsibilities well-defined?
- [ ] Is there a clear synchronization strategy?
- [ ] Are work stealing or thread pools used appropriately?
- [ ] Is async/await used where appropriate (Rust)?
- [ ] Are thread lifetimes managed correctly?
- [ ] Are thread locals used appropriately?

### Synchronization Primitives

- [ ] Are mutexes held for minimal time?
- [ ] Are reader-writer locks used where appropriate?
- [ ] Are atomics used correctly?
- [ ] Is memory ordering appropriate (Relaxed, Acquire, Release, SeqCst)?
- [ ] Are condition variables used correctly?
- [ ] Are barriers used appropriately?
- [ ] Are semaphores the right choice?

### Lock-Free Algorithms

If lock-free data structures are used:
- [ ] Is the algorithm from a peer-reviewed source?
- [ ] Are all memory orderings correct?
- [ ] Is the ABA problem considered?
- [ ] Are hazard pointers or epochs used for reclamation?
- [ ] Has correctness been formally verified?
- [ ] Have performance gains been measured?
- [ ] Is there a fallback to locked version?

### Data Races & Race Conditions

- [ ] Is all shared mutable state protected?
- [ ] Are data races impossible (proven via Send/Sync in Rust)?
- [ ] Are race conditions between operations prevented?
- [ ] Are TOCTOU bugs avoided?
- [ ] Is thread initialization synchronized?
- [ ] Is shutdown synchronized?
- [ ] Are signal handlers safe?

### Deadlock Prevention

- [ ] Is global lock ordering defined and documented?
- [ ] Are there any circular wait conditions?
- [ ] Can try_lock be used to avoid deadlock?
- [ ] Are locks released promptly?
- [ ] Is lock()/unlock() paired correctly?
- [ ] Are RAII lock guards used?
- [ ] Is there a deadlock detection mechanism?

## 3. FFI & Unsafe Code

### Safety Invariants (Rust)

- [ ] Are all safety invariants explicitly documented?
- [ ] Is unsafe code minimized?
- [ ] Are unsafe blocks justified with SAFETY comments?
- [ ] Are invariants upheld by safe wrapper APIs?
- [ ] Can safe code violate unsafe invariants?
- [ ] Are all raw pointer dereferences valid?
- [ ] Are transmutes sound?

### ABI Compatibility

- [ ] Are types repr(C) where crossing FFI boundary?
- [ ] Is calling convention specified (extern "C")?
- [ ] Are struct layouts compatible between languages?
- [ ] Is padding consistent?
- [ ] Are enums represented correctly?
- [ ] Are booleans handled correctly (C bool vs Rust bool)?
- [ ] Are function pointers compatible?

### Lifetime Management Across FFI

- [ ] Is ownership transfer explicit and documented?
- [ ] Are borrowed pointers valid for their usage?
- [ ] Are lifetimes conservatively estimated?
- [ ] Is use-after-free prevented?
- [ ] Are null pointers handled?
- [ ] Are opaque pointers used appropriately?
- [ ] Is memory allocated/freed by same side?

### Error Handling Across FFI

- [ ] How are errors communicated (return codes, errno, exceptions)?
- [ ] Are panics caught at FFI boundary (catch_unwind)?
- [ ] Is unwinding across FFI prevented?
- [ ] Are all C++ exceptions caught before returning to C/Rust?
- [ ] Are error states clearly documented?
- [ ] Are errors checked by caller?
- [ ] Is there a mechanism to query error details?

## 4. Performance

### Algorithmic Complexity

- [ ] What is the time complexity (Big-O)?
- [ ] What is the space complexity?
- [ ] Is the algorithm appropriate for input sizes?
- [ ] Are there better algorithms available?
- [ ] Are edge cases handled efficiently?
- [ ] Is worst-case behavior acceptable?
- [ ] Can complexity be amortized?

### Cache Behavior

- [ ] Is data accessed sequentially?
- [ ] Are hot data structures cache-friendly?
- [ ] Is cache line size considered (typically 64 bytes)?
- [ ] Is there excessive cache thrashing?
- [ ] Are data prefetches used where appropriate?
- [ ] Is temporal locality exploited?
- [ ] Is spatial locality exploited?

### Branch Prediction

- [ ] Are branches predictable?
- [ ] Can branches be eliminated (branchless code)?
- [ ] Are likely/unlikely hints used appropriately?
- [ ] Is computed goto/switch used for dispatch?
- [ ] Are function pointers minimized in hot paths?
- [ ] Is speculation exploited?
- [ ] Are branch mispredictions measured?

### SIMD & Vectorization

- [ ] Can operations be vectorized?
- [ ] Are data structures SIMD-friendly (aligned, contiguous)?
- [ ] Is auto-vectorization happening (check assembly)?
- [ ] Should explicit SIMD intrinsics be used?
- [ ] Are all lanes utilized?
- [ ] Is alignment correct for SIMD types?
- [ ] Is platform-specific SIMD handled?

### Zero-Cost Abstractions

- [ ] Do abstractions compile away (check assembly)?
- [ ] Is there unnecessary indirection (pointers, vtables)?
- [ ] Can generics be monomorphized?
- [ ] Is inlining happening appropriately?
- [ ] Are small functions marked inline?
- [ ] Are virtual functions avoided in hot paths?
- [ ] Is const propagation happening?

### Hot Path Optimization

- [ ] Are hot paths identified via profiling?
- [ ] Are allocations eliminated from hot paths?
- [ ] Is work moved out of hot paths?
- [ ] Are expensive operations avoided?
- [ ] Is work cached or precomputed?
- [ ] Are invariants hoisted out of loops?
- [ ] Is work distributed across cold paths?

## 5. Safety & Error Handling

### Error Propagation

- [ ] How are errors detected and reported?
- [ ] Are Result/Option types used in Rust?
- [ ] Are exceptions used appropriately in C++?
- [ ] Are error codes consistent?
- [ ] Are all error paths tested?
- [ ] Can errors be recovered from?
- [ ] Are errors logged with context?

### Invariant Enforcement

- [ ] Are invariants clearly stated?
- [ ] Are invariants checked with assertions?
- [ ] Are assertions disabled in release builds (if performance-critical)?
- [ ] Are contracts (pre/post conditions) enforced?
- [ ] What happens on invariant violation?
- [ ] Are invariants recoverable from?
- [ ] Are type invariants maintained (Rust types)?

### Resource Cleanup on Error

- [ ] Are resources cleaned up on all error paths?
- [ ] Is cleanup exception-safe (C++)?
- [ ] Is cleanup panic-safe (Rust)?
- [ ] Are there any resource leaks on error?
- [ ] Is RAII/Drop used consistently?
- [ ] Are finally blocks or scope guards used?
- [ ] Is two-phase initialization avoided?

### Input Validation

- [ ] Is all external input validated?
- [ ] Are bounds checked?
- [ ] Are integer overflows prevented?
- [ ] Are format strings validated?
- [ ] Are file paths sanitized?
- [ ] Are network inputs validated?
- [ ] Is validation defense-in-depth?

### Defense in Depth

- [ ] Are there multiple layers of protection?
- [ ] Are checks performed even in release builds where critical?
- [ ] Is there sanity checking throughout?
- [ ] Are redundant checks used for critical invariants?
- [ ] Is fault tolerance designed in?
- [ ] Are fail-safes in place?
- [ ] Is graceful degradation possible?

## 6. Hardware & Platform

### Platform Abstraction

- [ ] Is platform-specific code isolated?
- [ ] Are abstractions minimal and efficient?
- [ ] Is conditional compilation clean (#[cfg], #ifdef)?
- [ ] Are all target platforms supported?
- [ ] Is testing on all platforms feasible?
- [ ] Are platform differences documented?
- [ ] Is portability a goal or unnecessary?

### Hardware Interaction (if applicable)

- [ ] Is volatile used correctly for MMIO?
- [ ] Are memory barriers in place?
- [ ] Is memory ordering correct for hardware?
- [ ] Is DMA configured safely?
- [ ] Are interrupts handled correctly?
- [ ] Are hardware race conditions prevented?
- [ ] Is hardware documentation referenced?

### Endianness

- [ ] Is byte order handled explicitly?
- [ ] Are network protocols (big-endian) correct?
- [ ] Are file formats parsed correctly?
- [ ] Are conversions (to_be, to_le) used?
- [ ] Is endianness tested on both platforms?
- [ ] Are bitfields handled carefully?
- [ ] Are unions used safely for type punning?

## 7. Testing & Verification

### Unit Testing

- [ ] Can components be unit tested in isolation?
- [ ] Are dependencies mockable or injectable?
- [ ] Are test cases comprehensive?
- [ ] Are edge cases tested?
- [ ] Are error paths tested?
- [ ] Is test coverage measured?
- [ ] Are tests deterministic?

### Integration Testing

- [ ] Are component interactions tested?
- [ ] Are failure scenarios tested?
- [ ] Is system behavior tested end-to-end?
- [ ] Are performance tests in place?
- [ ] Is load testing performed?
- [ ] Are upgrade paths tested?
- [ ] Is backwards compatibility tested?

### Concurrency Testing

- [ ] Can race conditions be detected (TSan)?
- [ ] Are stress tests under high concurrency?
- [ ] Are deadlocks detected?
- [ ] Is synchronization validated?
- [ ] Are atomic operations tested?
- [ ] Is model checking used for lock-free code?
- [ ] Are timing-dependent bugs identified?

### Sanitizers & Analysis

- [ ] Is AddressSanitizer (ASan) used for memory errors?
- [ ] Is MemorySanitizer (MSan) used for uninitialized reads?
- [ ] Is UndefinedBehaviorSanitizer (UBSan) used?
- [ ] Is ThreadSanitizer (TSan) used for data races?
- [ ] Is fuzzing applied to parsers/inputs?
- [ ] Is static analysis (clippy, clang-tidy) run?
- [ ] Are all warnings treated as errors?

## 8. Documentation

### API Documentation

- [ ] Are public APIs documented?
- [ ] Are parameters and return values documented?
- [ ] Are error conditions documented?
- [ ] Are examples provided?
- [ ] Are edge cases and gotchas documented?
- [ ] Is thread-safety documented?
- [ ] Are lifetimes and ownership documented?

### Internal Documentation

- [ ] Are complex algorithms explained?
- [ ] Are invariants documented?
- [ ] Are lock ordering rules documented?
- [ ] Are performance characteristics noted?
- [ ] Are assumptions stated?
- [ ] Are unsafe blocks justified?
- [ ] Are TODOs and FIXMEs tracked?

### Code Clarity

- [ ] Are names meaningful and consistent?
- [ ] Is the code self-documenting?
- [ ] Is complexity justified and minimized?
- [ ] Are magic numbers avoided?
- [ ] Are comments explaining "why" not "what"?
- [ ] Is formatting consistent?
- [ ] Are comments up-to-date?

## Usage Notes

This checklist should be used iteratively:

1. **Initial Review**: Go through all sections applicable to the design
2. **Deep Dives**: Use specialized agents for detailed analysis:
   - `review-memory-safety` for memory management
   - `review-crypto` for cryptographic components
   - `review-performance` for performance-critical code
   - `coder-systems` for implementation review
3. **Documentation**: Create design review document with findings
4. **Follow-up**: Track action items and re-review after changes

Not all sections apply to every design. Focus on what's relevant.

## References

- C++ Core Guidelines: https://isocpp.github.io/CppCoreGuidelines/
- Rust API Guidelines: https://rust-lang.github.io/api-guidelines/
- The Rustonomicon: https://doc.rust-lang.org/nomicon/
- Concurrency in Practice: https://en.cppreference.com/w/cpp/thread
