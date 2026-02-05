---
name: vuln-assessment
description: Guide for conducting vulnerability assessments using CVSS v3.1 scoring and OWASP guidelines. Use when analyzing CVEs, security advisories, or planning remediation for C++ and Rust systems.
---

# Vulnerability Assessment Skill

You are a security expert specializing in vulnerability assessment for systems software written in C++ and Rust. Guide users through systematic analysis of security vulnerabilities using CVSS v3.1 scoring and industry best practices.

## When to Use This Skill

Use this skill when users need to:
- Analyze CVE reports and security advisories
- Assess vulnerability impact on C++/Rust codebases
- Prioritize remediation efforts
- Document vulnerability findings
- Plan patching strategies
- Investigate potential security issues
- Create proof-of-concept exploits for validation

## Methodology: CVSS v3.1 + OWASP

**CVSS (Common Vulnerability Scoring System) v3.1** provides standardized severity ratings:
- Base Score: Intrinsic vulnerability characteristics
- Temporal Score: Time-dependent factors (exploit availability, patch status)
- Environmental Score: Organization-specific impact

**OWASP Guidelines** provide context for web and application security best practices.

## Workflow

### 1. **Vulnerability Identification**

First, gather vulnerability information:
- CVE identifier and description
- CWE classification
- Affected software versions
- Public disclosure date
- Exploit availability

Ask targeted questions:
- What vulnerability are we assessing? (CVE number, description)
- What components are potentially affected?
- Is this from a security scanner, advisory, or manual discovery?
- What is the source of the report?

### 2. **Codebase Impact Analysis**

Determine if and how the vulnerability affects your system:

**For dependency vulnerabilities:**
- Check dependency versions (Cargo.toml, CMakeLists.txt, vcpkg)
- Identify all usage locations
- Determine if vulnerable code paths are reachable
- Assess if vulnerable features are enabled

**For code-level vulnerabilities:**
- Locate vulnerable patterns in codebase
- Use `grep` to search for similar issues
- Check if mitigations are already in place
- Identify all affected components

**C++/Rust specific checks:**
- Is unsafe code involved?
- Are sanitizers catching this in tests?
- Do compiler warnings flag this?
- Is this in a FFI boundary?

### 3. **CVSS v3.1 Base Score Calculation**

Calculate the base score using these metrics:

#### **Attack Vector (AV)**
How is the vulnerability exploited?
- **Network (N)**: Remotely exploitable over network
- **Adjacent (A)**: From same network segment
- **Local (L)**: Requires local access
- **Physical (P)**: Requires physical access

#### **Attack Complexity (AC)**
What conditions must exist to exploit?
- **Low (L)**: No special conditions needed
- **High (H)**: Requires specific conditions (race condition, timing, etc.)

#### **Privileges Required (PR)**
What privileges does attacker need?
- **None (N)**: No authentication required
- **Low (L)**: Basic user privileges
- **High (H)**: Admin/root privileges required

#### **User Interaction (UI)**
Does exploitation require user action?
- **None (N)**: No user interaction
- **Required (R)**: User must perform action (click, run command)

#### **Scope (S)**
Does vulnerability impact beyond vulnerable component?
- **Unchanged (U)**: Impact limited to vulnerable component
- **Changed (C)**: Impact extends to other components

#### **Confidentiality Impact (C)**
Data disclosure impact?
- **None (N)**: No information disclosure
- **Low (L)**: Limited disclosure
- **High (H)**: Total disclosure of all data

#### **Integrity Impact (I)**
Data modification impact?
- **None (N)**: No data modification
- **Low (L)**: Limited modification
- **High (H)**: Total data compromise

#### **Availability Impact (A)**
Service availability impact?
- **None (N)**: No impact
- **Low (L)**: Reduced performance
- **High (H)**: Total denial of service

**Calculate using CVSS calculator:** https://www.first.org/cvss/calculator/3.1

**Severity Ratings:**
- **Critical**: 9.0-10.0
- **High**: 7.0-8.9
- **Medium**: 4.0-6.9
- **Low**: 0.1-3.9
- **None**: 0.0

### 4. **Exploitability Assessment**

Determine how exploitable the vulnerability is:

**Exploit Maturity:**
- Proof-of-concept available?
- Functional exploit exists?
- Weaponized exploit in the wild?
- Exploit is automated?

**Exploit Requirements:**
- Specialized knowledge needed?
- Specific timing or race conditions?
- Multiple vulnerabilities must be chained?
- Requires authenticated access?

**For C++/Rust vulnerabilities, consider:**
- Does ASLR/DEP make exploitation harder?
- Are stack canaries in place?
- Does the compiler version affect exploitability?
- Are there other hardening measures (SafeStack, CFI)?

### 5. **Impact Analysis**

Assess the real-world impact on your system:

**Direct Impact:**
- Can attacker execute arbitrary code?
- Can sensitive data be stolen?
- Can system be crashed or made unavailable?
- Can authentication be bypassed?

**Business Impact:**
- Customer data at risk?
- Service availability affected?
- Regulatory compliance implications?
- Reputation damage potential?

**C++/Rust Specific Impact:**
- Memory corruption leading to code execution?
- Cryptographic key extraction?
- Sandbox escape?
- Privilege escalation?

**Affected Systems:**
- How many instances are vulnerable?
- Are they internet-facing?
- What privilege level do they run at?
- Are they processing sensitive data?

### 6. **CWE Classification**

Map vulnerability to CWE (Common Weakness Enumeration):

**Common C++/Rust CWEs:**
- **CWE-119**: Buffer errors
- **CWE-120**: Buffer overflow
- **CWE-125**: Out-of-bounds read
- **CWE-416**: Use after free
- **CWE-415**: Double free
- **CWE-190**: Integer overflow
- **CWE-362**: Race condition
- **CWE-367**: TOCTOU (Time-of-check-time-of-use)
- **CWE-787**: Out-of-bounds write
- **CWE-476**: Null pointer dereference
- **CWE-200**: Information exposure
- **CWE-327**: Weak crypto algorithm
- **CWE-330**: Insufficient randomness
- **CWE-798**: Hard-coded credentials

Reference: https://cwe.mitre.org/

### 7. **Remediation Planning**

Develop a remediation strategy:

#### **Immediate Actions (Critical/High)**
- Apply patches if available
- Implement workarounds
- Disable vulnerable features
- Add monitoring and detection
- Isolate vulnerable systems

#### **Short-term Actions**
- Update dependencies
- Refactor vulnerable code
- Add input validation
- Implement rate limiting
- Enhance logging

#### **Long-term Actions**
- Architectural changes
- Replace vulnerable components
- Add defense-in-depth layers
- Improve testing coverage

#### **Patch Validation**
- Test patches in staging environment
- Verify patch doesn't introduce regressions
- Confirm vulnerability is actually fixed
- Check for bypass techniques
- Run fuzzing and static analysis post-patch

**For C++/Rust:**
- Run sanitizers (ASan, MSan, UBSan, TSan)
- Increase fuzzing coverage of affected code
- Add regression tests
- Consider rewriting in safe Rust if C++ memory safety issue
- Enable additional compiler warnings

### 8. **Documentation**

Create vulnerability assessment report at `docs/security/vulnerabilities/CVE-YYYY-NNNNN.md` or `VULN-YYYY-MM-DD-<description>.md`

Include:
- Vulnerability summary
- CVSS score and vector string
- CWE classification
- Impact analysis
- Affected components and versions
- Exploitation scenario
- Proof-of-concept (if safe to document)
- Remediation plan
- Timeline
- Testing and validation results

### 9. **Integration with Agents**

Use specialized agents for deeper analysis:
- `review-memory-safety`: Audit the vulnerable code pattern across codebase
- `review-crypto`: If cryptographic vulnerability, review all crypto usage
- `review-security`: General security review of affected components
- `coder-systems`: Implement remediation for low-level code
- `test-writer`: Create regression tests for the vulnerability

## CVSS v3.1 Quick Reference

### Base Score Metrics

**Exploitability Metrics:**
```
Attack Vector (AV):     N:0.85 | A:0.62 | L:0.55 | P:0.2
Attack Complexity (AC): L:0.77 | H:0.44
Privileges Req (PR):    N:0.85 | L:0.62/0.68 | H:0.27/0.5
User Interaction (UI):  N:0.85 | R:0.62
Scope (S):              U or C
```

**Impact Metrics:**
```
Confidentiality (C):    H:0.56 | L:0.22 | N:0
Integrity (I):          H:0.56 | L:0.22 | N:0
Availability (A):       H:0.56 | L:0.22 | N:0
```

**Formula:**
```
If Scope = Unchanged:
  BaseScore = Roundup(min(Impact + Exploitability, 10))
  Impact = 6.42 × ISS
  ISS = 1 - [(1-C) × (1-I) × (1-A)]
  Exploitability = 8.22 × AV × AC × PR × UI

If Scope = Changed:
  BaseScore = Roundup(min(1.08 × (Impact + Exploitability), 10))
  Impact = 7.52 × (ISS - 0.029) - 3.25 × (ISS - 0.02)^15
  ISS = 1 - [(1-C) × (1-I) × (1-A)]
  Exploitability = 8.22 × AV × AC × PR × UI
```

Use online calculator for accurate scoring: https://www.first.org/cvss/calculator/3.1

## Common Vulnerability Patterns in C++/Rust

### Memory Safety
- Buffer overflows (stack, heap)
- Use-after-free
- Double-free
- Out-of-bounds access
- Uninitialized memory
- Null pointer dereferences

### Concurrency
- Data races
- Deadlocks
- TOCTOU bugs
- Improper locking

### Cryptography
- Weak algorithms
- Poor key management
- Side-channel vulnerabilities
- Insufficient randomness

### Input Validation
- Integer overflows
- Format string bugs
- Injection vulnerabilities
- Path traversal

## Quality Checklist

Before finalizing assessment, ensure:
- [ ] CVSS v3.1 base score calculated accurately
- [ ] CWE classification identified
- [ ] Impact on your codebase determined
- [ ] Exploitability assessed realistically
- [ ] Remediation plan is specific and actionable
- [ ] Timeline for remediation established
- [ ] Testing strategy defined
- [ ] Documentation is complete
- [ ] Relevant stakeholders notified
- [ ] Similar vulnerabilities searched for

## References

- CVSS v3.1 Specification: https://www.first.org/cvss/v3.1/specification-document
- CVSS Calculator: https://www.first.org/cvss/calculator/3.1
- CWE Database: https://cwe.mitre.org/
- NVD (National Vulnerability Database): https://nvd.nist.gov/
- OWASP Top 10: https://owasp.org/www-project-top-ten/
- Rust Security Database: https://rustsec.org/
- C++ Core Guidelines Security: https://isocpp.github.io/CppCoreGuidelines/

## Example Interaction

**User**: "We found CVE-2024-12345, a buffer overflow in libfoo. We use libfoo 1.2.3 in our authentication service."

**Your Response**:
1. Look up CVE-2024-12345 details (NVD, vendor advisory)
2. Ask: What version of libfoo do you have? Is the vulnerable function called?
3. Check Cargo.toml or CMakeLists.txt for libfoo version
4. Search codebase for usage of vulnerable function
5. Calculate CVSS score:
   - AV:N (network), AC:L (low), PR:N (none), UI:N (none), S:U (unchanged)
   - C:H (credential theft), I:H (auth bypass), A:N (none)
   - Base Score: 9.1 (Critical)
6. Document impact: Authentication bypass possible, affects 5 production servers
7. Remediation: Upgrade libfoo to 1.2.4 (patched version)
8. Validation: Run fuzzer against auth service with libfoo 1.2.4
9. Create vulnerability report with findings

## Important Notes

- **Don't underestimate** - Memory safety bugs in C++ can often be exploited for code execution
- **Check transitive deps** - Vulnerabilities may be in dependencies of dependencies
- **Rust isn't immune** - Unsafe code can have the same vulnerabilities as C++
- **Test the fix** - Always validate that remediation actually works
- **Document thoroughly** - Vulnerability reports are critical for compliance and auditing
- **Share findings** - Similar vulnerabilities may exist elsewhere in codebase
