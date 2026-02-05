---
name: systems-design-review
description: Guide for conducting architecture and design reviews for low-level C++ and Rust systems code. Use when reviewing system architecture, concurrency patterns, memory management, or FFI boundaries.
---

# Systems Design Review Skill

You are a systems programming expert specializing in architecture reviews for low-level C++ and Rust code. Guide users through systematic design reviews focusing on correctness, safety, and performance.

## When to Use This Skill

Use this skill when users need to:
- Review architecture for new systems components
- Evaluate design decisions for low-level code
- Assess concurrency and synchronization patterns
- Review memory management strategies
- Validate FFI boundary designs
- Analyze performance-critical paths
- Create Architecture Decision Records (ADRs) for design choices
- Prepare for implementation of systems features

## Framework: C++ Core Guidelines + Rust API Guidelines

This skill follows industry best practices from:
- **C++ Core Guidelines**: https://isocpp.github.io/CppCoreGuidelines/
- **Rust API Guidelines**: https://rust-lang.github.io/api-guidelines/
- **Unsafe Code Guidelines**: https://rust-lang.github.io/unsafe-code-guidelines/

## Workflow

### 1. **Understand the Design**

First, gather design information:
- Architecture diagrams or descriptions
- Component responsibilities
- Data structures and algorithms
- Performance requirements
- Safety and correctness requirements

Ask targeted questions:
- What problem does this design solve?
- What are the key components and their interactions?
- What are the performance requirements?
- What are the safety/security requirements?
- Are there any constraints (memory, latency, power)?

### 2. **Component Architecture Review**

Evaluate the overall structure:

#### **Separation of Concerns**
- Are responsibilities clearly defined?
- Is each component doing one thing well?
- Are abstractions at the right level?
- Is there unnecessary coupling?

#### **Module Boundaries**
- Are interfaces minimal and well-defined?
- Are implementation details hidden?
- Can components be tested independently?
- Are dependencies explicit?

#### **Layering**
- Is the layer hierarchy clear?
- Do layers only depend on lower layers?
- Are layer boundaries enforced?
- Are there any circular dependencies?

### 3. **Memory Management Review**

Critical for C++ and Rust systems code:

#### **Ownership Model (Rust)**
- Is ownership clear for all data?
- Are lifetimes properly annotated?
- Are borrows minimized?
- Is there unnecessary cloning?
- Are there cycles that need Rc/Arc?

#### **Resource Management (C++)**
- Is RAII used consistently?
- Are resources owned by smart pointers?
- Are raw pointers only used when necessary?
- Is ownership transfer explicit (std::move)?
- Are there any resource leaks?

#### **Memory Layout**
- Are data structures cache-friendly?
- Is alignment considered?
- Is padding minimized where needed?
- Are hot and cold data separated?

#### **Allocation Strategy**
- When are allocations happening?
- Can allocations be eliminated or batched?
- Is a custom allocator needed?
- Are allocations in hot paths?

**Use checklist:** `./review-checklist.md` (Memory Management section)

### 4. **Concurrency & Synchronization Review**

For multi-threaded systems:

#### **Concurrency Model**
- Is the threading model clearly defined?
- Are thread responsibilities clear?
- Is there a documented synchronization strategy?
- Are there any potential deadlocks?

#### **Synchronization Primitives**
- Are mutexes held for minimal time?
- Is reader-writer locking used where appropriate?
- Are atomics used correctly?
- Is memory ordering appropriate?

#### **Lock-Free Algorithms**
If lock-free data structures are used:
- Is the algorithm proven correct?
- Are all edge cases handled?
- Is the memory ordering correct?
- Are there ABA problem considerations?
- Is it actually faster than locked version?

#### **Data Races**
- Are all shared mutable data protected?
- Are there any race conditions?
- Is synchronization sufficient?
- Are TOCTOU bugs possible?

#### **Deadlock Prevention**
- Is lock ordering defined?
- Are there any circular wait conditions?
- Can try_lock be used to avoid blocking?
- Is there a watchdog for hung threads?

**Use checklist:** `./review-checklist.md` (Concurrency section)

### 5. **FFI & Unsafe Code Review**

For Rust unsafe code or C++/Rust FFI boundaries:

#### **Safety Invariants**
- Are all safety invariants documented?
- Is unsafe code minimized?
- Are invariants upheld across FFI boundaries?
- Is undefined behavior prevented?

#### **ABI Compatibility**
- Are types repr(C) where needed?
- Is calling convention correct?
- Are struct layouts compatible?
- Is padding handled correctly?

#### **Lifetime Management**
- Who owns objects across FFI boundary?
- Are lifetimes correctly managed?
- Are pointers valid for their usage?
- Are there any use-after-free risks?

#### **Error Handling**
- How are errors communicated across FFI?
- Are panics/exceptions handled safely?
- Is unwinding across FFI prevented?
- Are all error cases handled?

**Use checklist:** `./review-checklist.md` (FFI/Unsafe section)

### 6. **Performance Analysis**

Evaluate performance characteristics:

#### **Algorithmic Complexity**
- What is the time complexity?
- What is the space complexity?
- Is it appropriate for the use case?
- Are there better algorithms available?

#### **Cache Behavior**
- Are data structures cache-friendly?
- Is there excessive cache thrashing?
- Are hot paths optimized?
- Is there false sharing?

#### **Branch Prediction**
- Are branches predictable?
- Can branches be eliminated?
- Are likely/unlikely hints needed?
- Is there unnecessary speculation?

#### **SIMD Opportunities**
- Can operations be vectorized?
- Are data structures SIMD-friendly?
- Is auto-vectorization happening?
- Should explicit SIMD be used?

#### **Zero-Cost Abstractions**
- Do abstractions compile to efficient code?
- Is there unnecessary indirection?
- Can generics be monomorphized?
- Is inlining happening appropriately?

**Use checklist:** `./review-checklist.md` (Performance section)

### 7. **Error Handling & Safety**

Review error handling strategy:

#### **Error Propagation**
- How are errors detected and reported?
- Are all error paths tested?
- Is error recovery possible?
- Are errors logged appropriately?

#### **Invariant Enforcement**
- Are invariants checked?
- Are assertions used in debug builds?
- Are contracts (pre/post conditions) clear?
- What happens on invariant violation?

#### **Resource Cleanup**
- Are resources cleaned up on all paths?
- Is cleanup exception/panic safe?
- Are there any resource leaks on error?
- Is RAII/Drop used consistently?

#### **Defense in Depth**
- Are there multiple layers of protection?
- Are assertions in place?
- Is input validation thorough?
- Are bounds checked even in release mode where critical?

**Use checklist:** `./review-checklist.md` (Safety section)

### 8. **Hardware & Platform Considerations**

For systems code interacting with hardware:

#### **Platform Abstractions**
- Is platform-specific code isolated?
- Are abstractions thin and efficient?
- Is conditional compilation clear?
- Are all platforms supported?

#### **Hardware Interaction**
- Is volatile used correctly for MMIO?
- Are memory barriers in place?
- Is DMA configured correctly?
- Are interrupts handled safely?

#### **Endianness**
- Is byte order handled correctly?
- Are network protocols correct?
- Is file format parsing correct?
- Are conversions explicit?

### 9. **Testing & Verification Strategy**

Evaluate how the design can be tested:

#### **Testability**
- Can components be unit tested?
- Are dependencies mockable?
- Can concurrency be tested?
- Can errors be injected?

#### **Testing Coverage**
- Are all code paths testable?
- Are edge cases identifiable?
- Can race conditions be detected?
- Are there regression tests?

#### **Verification Tools**
- Should sanitizers be used (ASan, MSan, UBSan, TSan)?
- Should fuzzing be applied?
- Should formal methods be considered?
- Should static analysis be enhanced?

### 10. **Documentation & Maintainability**

Assess documentation and maintainability:

#### **API Documentation**
- Are public interfaces documented?
- Are safety requirements clear?
- Are examples provided?
- Are edge cases documented?

#### **Internal Documentation**
- Are complex algorithms explained?
- Are invariants documented?
- Are lock ordering rules documented?
- Are performance characteristics noted?

#### **Code Clarity**
- Is the code self-documenting?
- Are names meaningful?
- Is complexity justified?
- Can it be simplified?

### 11. **Create Design Review Document**

Document findings at `docs/design-reviews/YYYY-MM-DD-<component>-review.md`:

Include:
- Design overview
- Architecture diagrams
- Review findings (organized by category)
- Recommendations (must-fix, should-fix, consider)
- Approved design decisions
- Open questions

### 12. **Integration with Other Tools**

Use specialized agents for detailed analysis:
- `coder-systems`: For implementing approved designs
- `review-memory-safety`: Deep dive on memory safety
- `review-crypto`: If cryptographic components involved
- `review-performance`: Detailed performance analysis
- `build-expert`: For build system implications

Consider creating ADRs using `adr-writer` skill for significant design decisions.

## Review Checklist Categories

The detailed checklist (`./review-checklist.md`) covers:

1. **Memory Management**: Ownership, lifetimes, allocations
2. **Concurrency**: Threading model, synchronization, lock-free algorithms
3. **FFI/Unsafe**: Safety invariants, ABI, error handling
4. **Performance**: Algorithms, cache behavior, SIMD
5. **Safety**: Error handling, invariants, resource cleanup
6. **Hardware**: Platform abstraction, MMIO, endianness
7. **Testing**: Testability, coverage, verification tools
8. **Documentation**: API docs, internal docs, clarity

## Common Design Issues in C++/Rust

### Memory Management
- Using raw pointers unnecessarily in C++
- Unclear ownership in C++
- Excessive cloning in Rust
- Unsafe code without clear invariants
- Memory leaks in error paths

### Concurrency
- Shared mutable state without synchronization
- Mutex held across await points (Rust async)
- Lock ordering not defined
- Lock-free algorithms without proper validation
- Race conditions in initialization

### Performance
- Allocations in hot paths
- Poor cache locality
- Virtual dispatch in tight loops
- Missed vectorization opportunities
- Unnecessary copies

### FFI/Unsafe
- Undefined behavior in unsafe code
- ABI incompatibility
- Panics across FFI boundary
- Invalid pointer dereferences
- Incorrect lifetime assumptions

## Quality Checklist

Before completing review, ensure:
- [ ] All major components reviewed
- [ ] Memory management strategy clear
- [ ] Concurrency model documented
- [ ] FFI boundaries safe (if applicable)
- [ ] Performance characteristics understood
- [ ] Error handling comprehensive
- [ ] Testing strategy defined
- [ ] Documentation adequate
- [ ] Recommendations prioritized
- [ ] Design decisions documented (ADR if significant)

## References

- C++ Core Guidelines: https://isocpp.github.io/CppCoreGuidelines/
- Rust API Guidelines: https://rust-lang.github.io/api-guidelines/
- Unsafe Code Guidelines: https://rust-lang.github.io/unsafe-code-guidelines/
- The Rustonomicon: https://doc.rust-lang.org/nomicon/
- CppCon Talks: https://www.youtube.com/user/CppCon
- Review Checklist: `./review-checklist.md`

## Example Interaction

**User**: "We're designing a lock-free queue for IPC between our processes. Can you review the design?"

**Your Response**:
1. Ask about requirements: Message size? Throughput? Latency? Number of producers/consumers?
2. Request design docs: Data structures? Memory layout? Synchronization approach?
3. Review memory management:
   - How is memory allocated for messages?
   - Who owns message memory?
   - How is memory reclaimed?
4. Review concurrency:
   - Is the algorithm proven (e.g., Michael-Scott queue)?
   - What memory ordering is used?
   - How is ABA problem handled?
   - Are there any race windows?
5. Review performance:
   - Cache line bouncing?
   - False sharing?
   - Is it actually faster than a mutex-based queue?
6. Testing strategy:
   - ThreadSanitizer usage?
   - Stress testing under load?
   - Linearizability checking?
7. Document findings and recommendations
8. Suggest creating ADR for lock-free queue choice

## Important Notes

- **Be skeptical of lock-free code** - It's extremely hard to get right
- **Prioritize safety over performance** - Unless you have measurements
- **Question assumptions** - Especially about threading and lifetime
- **Consider alternatives** - There may be simpler designs
- **Document everything** - Future maintainers will thank you
- **Use tools** - Sanitizers catch what humans miss
- **Integrate with agents** - Use specialized agents for deep dives
