# CVSS v3.1 Quick Reference Guide

## Overview

CVSS (Common Vulnerability Scoring System) v3.1 provides a standardized method for rating the severity of security vulnerabilities. Scores range from 0.0 to 10.0.

## Severity Ratings

| Rating   | Score Range | Description |
|----------|-------------|-------------|
| None     | 0.0         | No impact   |
| Low      | 0.1-3.9     | Minimal risk, low priority |
| Medium   | 4.0-6.9     | Moderate risk, plan remediation |
| High     | 7.0-8.9     | Serious risk, prioritize remediation |
| Critical | 9.0-10.0    | Severe risk, immediate action required |

## Base Score Metrics

The base score represents the intrinsic characteristics of a vulnerability.

### Exploitability Metrics

#### Attack Vector (AV)
How the vulnerability is exploited:

- **Network (N)**: Vulnerability is remotely exploitable. The vulnerable component is bound to the network stack. Examples: remote buffer overflow, remote SQL injection.
- **Adjacent Network (A)**: Exploitable only from adjacent network (same physical or logical network). Examples: Bluetooth, local network ARP spoofing.
- **Local (L)**: Requires local access or local user account. Examples: privilege escalation, local file read.
- **Physical (P)**: Requires physical access to the device. Examples: cold boot attacks, hardware implants.

#### Attack Complexity (AC)
Complexity of the attack beyond access to the vulnerable system:

- **Low (L)**: No special preparation or conditions needed. Attack can be repeated reliably.
- **High (H)**: Requires considerable preparation or execution against specific conditions. Examples: race conditions, weakening of security features, need to gather target-specific information.

#### Privileges Required (PR)
Privileges attacker must have before exploiting:

- **None (N)**: No authentication or privileges needed
- **Low (L)**: Basic user privileges (non-privileged account)
- **High (H)**: Administrator, root, or other high-privilege account required

#### User Interaction (UI)
Does exploitation require a separate user to participate?

- **None (N)**: Attacker can exploit without user participation
- **Required (R)**: Successful exploitation requires a user to perform some action (open email attachment, click link, run application)

#### Scope (S)
Does the vulnerability affect resources beyond its original security scope?

- **Unchanged (U)**: Impact is constrained to the vulnerable component
- **Changed (C)**: Impact extends beyond the vulnerable component. Examples: escaping a sandbox, privilege escalation, cross-site scripting affecting other users

### Impact Metrics

#### Confidentiality Impact (C)
Impact to data confidentiality:

- **None (N)**: No impact to confidentiality
- **Low (L)**: Some information disclosure, but attacker has limited control over what information is obtained
- **High (H)**: Total disclosure of information, or ability to disclose any information in the system

#### Integrity Impact (I)
Impact to data integrity:

- **None (N)**: No impact to integrity
- **Low (L)**: Limited ability to modify data, or only certain files/data can be modified
- **High (H)**: Total compromise of data integrity, ability to modify any data in the system

#### Availability Impact (A)
Impact to system availability:

- **None (N)**: No impact to availability
- **Low (L)**: Reduced performance or interruptions in resource availability
- **High (H)**: Total denial of service or complete loss of availability

## CVSS Vector String

CVSS vectors encode the metrics in a compact string format:

```
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H
```

This example represents:
- Attack Vector: Network
- Attack Complexity: Low
- Privileges Required: None
- User Interaction: None
- Scope: Unchanged
- Confidentiality Impact: High
- Integrity Impact: High
- Availability Impact: High
- **Base Score: 9.8 (Critical)**

## Common Vulnerability Scenarios for C++/Rust

### Remote Code Execution (RCE) - Network Accessible
**Example**: Buffer overflow in network-facing service
```
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H
Base Score: 9.8 (Critical)
```

### Local Privilege Escalation
**Example**: Use-after-free in privileged service
```
CVSS:3.1/AV:L/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H
Base Score: 7.8 (High)
```

### Memory Disclosure
**Example**: Out-of-bounds read leaking sensitive data
```
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N
Base Score: 7.5 (High)
```

### Denial of Service (Crash)
**Example**: Null pointer dereference causing crash
```
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:H
Base Score: 7.5 (High)
```

### Cryptographic Weakness
**Example**: Side-channel timing attack on crypto implementation
```
CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:U/C:H/I:N/A:N
Base Score: 5.9 (Medium)
```

### Race Condition (TOCTOU)
**Example**: Time-of-check-time-of-use in file operations
```
CVSS:3.1/AV:L/AC:H/PR:L/UI:N/S:U/C:H/I:H/A:H
Base Score: 7.0 (High)
```

### Sandbox Escape
**Example**: FFI boundary violation allowing escape
```
CVSS:3.1/AV:L/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:H
Base Score: 8.8 (High)
```

## Temporal Metrics (Optional)

Temporal metrics measure characteristics that change over time:

### Exploit Code Maturity (E)
- **Not Defined (X)**: Skip this metric
- **Unproven (U)**: No exploit exists or is theoretical
- **Proof-of-Concept (P)**: PoC code exists
- **Functional (F)**: Functional exploit exists
- **High (H)**: Automated, no expertise required

### Remediation Level (RL)
- **Not Defined (X)**: Skip this metric
- **Official Fix (O)**: Complete vendor solution available
- **Temporary Fix (T)**: Official temporary fix/workaround
- **Workaround (W)**: Unofficial workaround exists
- **Unavailable (U)**: No solution available

### Report Confidence (RC)
- **Not Defined (X)**: Skip this metric
- **Unknown (U)**: No reports or unconfirmed
- **Reasonable (R)**: Significant uncertainty
- **Confirmed (C)**: Detailed reports, confirmed by vendor

## Environmental Metrics (Optional)

Modified metrics based on your environment's characteristics. These allow you to adjust CVSS scores for organization-specific factors.

## Using CVSS Calculator

For accurate scoring, use the official calculator:
https://www.first.org/cvss/calculator/3.1

1. Select each metric value
2. Calculator automatically computes the score
3. Copy the vector string for documentation
4. Use the score for prioritization

## C++/Rust Specific Considerations

### Memory Safety Vulnerabilities
Most memory safety bugs (buffer overflows, use-after-free) typically score **High to Critical**:
- Often remotely exploitable (AV:N)
- Lead to code execution (C:H/I:H/A:H)
- May not require authentication (PR:N)

### Rust Safety Claims
Vulnerabilities in Rust's unsafe code or soundness holes may have:
- Higher **Scope** impact (S:C) if it breaks safety guarantees
- Higher **Exploitability** than expected given Rust's reputation

### Cryptographic Vulnerabilities
Side-channel attacks often have:
- Higher **Attack Complexity** (AC:H) - requires sophisticated techniques
- But still High impact if successful (C:H)

### Dependency Vulnerabilities
Consider:
- **Reachability**: Is the vulnerable function actually called?
- **Exposure**: Is the component network-facing?
- May lower the effective score if not exploitable in your context

## Common Mistakes

1. **Overestimating Attack Complexity**: Just because exploitation is non-trivial doesn't mean AC:H. AC:H requires special conditions.

2. **Ignoring Scope Changes**: Sandbox escapes, VM escapes, privilege escalations often change scope (S:C).

3. **Underestimating Impact**: Memory corruption in C++ can often lead to full code execution, not just crashes.

4. **Not Considering Environment**: A vulnerability in an internal-only service has different real-world risk than internet-facing.

5. **Confusing Difficulty with Complexity**: Advanced exploit techniques (ROP, heap feng shui) don't necessarily mean AC:H if conditions are deterministic.

## Quick Decision Tree

**Is it remotely exploitable?** → AV:N  
**Does it require authentication?** → If no: PR:N  
**Does it lead to code execution?** → C:H, I:H, A:H  
**Can it be exploited reliably?** → AC:L  
**Does it escape sandbox/VM?** → S:C  

→ **Likely Critical or High severity**

## References

- CVSS v3.1 Specification: https://www.first.org/cvss/v3.1/specification-document
- CVSS Calculator: https://www.first.org/cvss/calculator/3.1
- CVSS User Guide: https://www.first.org/cvss/user-guide
- Examples: https://www.first.org/cvss/examples
