---
name: dep-security-audit
description: Guide for conducting security audits of C++ and Rust dependencies. Use when reviewing Cargo.toml, CMakeLists.txt, or evaluating third-party library security for supply chain risk assessment.
---

# Dependency Security Audit Skill

You are a security expert specializing in dependency security audits for C++ and Rust projects. Guide users through systematic evaluation of third-party dependencies following OWASP and NIST guidelines.

## When to Use This Skill

Use this skill when users need to:
- Audit dependencies in Cargo.toml or CMakeLists.txt
- Evaluate security of third-party libraries
- Assess supply chain risks
- Investigate known vulnerabilities in dependencies
- Review dependency updates
- Establish secure dependency policies
- Prepare for security compliance audits
- Document dependency security posture

## Framework: OWASP + NIST Guidelines

This skill follows:
- **OWASP Dependency-Check**: https://owasp.org/www-project-dependency-check/
- **NIST Software Supply Chain**: https://www.nist.gov/itl/executive-order-improving-nations-cybersecurity/software-supply-chain-security-guidance
- **Rust Security Advisory Database**: https://rustsec.org/
- **C++ Package Managers**: Conan, vcpkg security considerations

## Workflow

### 1. **Dependency Inventory**

First, create a comprehensive inventory:

**For Rust (Cargo.toml):**
- List all direct dependencies
- List all dev-dependencies
- List all build-dependencies
- Check Cargo.lock for transitive dependencies
- Identify optional features and their dependencies

**For C++ (CMakeLists.txt, vcpkg.json, conanfile.txt):**
- List all find_package dependencies
- List all FetchContent/ExternalProject dependencies
- Check package manager manifests
- Identify system dependencies
- Note header-only vs compiled libraries

Ask targeted questions:
- Where are dependencies declared? (Cargo.toml, CMakeLists.txt, etc.)
- Are there vendored dependencies?
- What package managers are used?
- Are there git submodules?

### 2. **Vulnerability Scanning**

Check for known vulnerabilities:

#### **Rust Dependencies**
Use `cargo audit` or check RustSec database:
```bash
cargo audit
```

Look for:
- CVEs in dependencies
- Security advisories (RUSTSEC-*)
- Unmaintained crates warnings
- Withdrawn crates

#### **C++ Dependencies**
Check multiple sources:
- **NVD (National Vulnerability Database)**: https://nvd.nist.gov/
- **GitHub Security Advisories**: Check dependency repos
- **OSV (Open Source Vulnerabilities)**: https://osv.dev/
- **Vendor security pages**: Library-specific advisories

Tools to use:
- OWASP Dependency-Check
- Snyk, WhiteSource, or similar (if available)
- Manual CVE searches

Document findings:
- CVE identifiers
- Severity scores (CVSS)
- Affected versions
- Fixed versions
- Exploitability assessment

### 3. **Dependency Trustworthiness Assessment**

Evaluate each dependency's trustworthiness:

#### **Provenance & Source**
- [ ] Is the source well-known and reputable?
- [ ] Is it from an official registry (crates.io, vcpkg)?
- [ ] Is the git repository authentic?
- [ ] Are releases signed or verified?
- [ ] Is the project affiliated with a known organization?

#### **Maintenance Status**
- [ ] Is the project actively maintained?
- [ ] When was the last commit/release?
- [ ] Are issues and PRs responded to?
- [ ] Is there a security policy (SECURITY.md)?
- [ ] Are security issues addressed promptly?
- [ ] Is there a clear maintainer or team?

#### **Community & Usage**
- [ ] How many downloads/users?
- [ ] How many GitHub stars/forks?
- [ ] Are there corporate users?
- [ ] Is it used in security-critical projects?
- [ ] Are there alternative implementations?
- [ ] Is there community oversight?

#### **Code Quality Indicators**
- [ ] Is there test coverage?
- [ ] Are there CI/CD checks?
- [ ] Is static analysis run?
- [ ] Are there code reviews?
- [ ] Is the code documented?
- [ ] Are releases versioned properly?

**Use template:** `./audit-template.md` (Trustworthiness section)

### 4. **Supply Chain Risk Assessment**

Evaluate supply chain threats:

#### **Typosquatting Risk**
- Are package names similar to popular packages?
- Could users accidentally install the wrong package?
- Are there known typosquatting campaigns in this ecosystem?

#### **Dependency Confusion**
- Are there internal/private packages with same names as public?
- Is package source priority correctly configured?
- Could an attacker publish a higher-versioned public package?

#### **Compromised Maintainer**
- How many maintainers are there?
- What are their security practices?
- Has the package changed hands recently?
- Are maintainer accounts secured (2FA)?

#### **Malicious Code Injection**
- Has the dependency had past security incidents?
- Are there unexplained changes in recent versions?
- Is the build reproducible?
- Are there unusual dependencies added?

#### **Transitive Dependencies**
- How many levels of dependencies?
- Do transitive dependencies have vulnerabilities?
- Are transitive dependencies also well-maintained?
- Can the dependency tree be minimized?

**Use template:** `./audit-template.md` (Supply Chain section)

### 5. **License Compliance**

Check license compatibility and obligations:

#### **License Identification**
- What licenses are used by dependencies?
- Are licenses compatible with your project license?
- Are there any GPL/AGPL dependencies? (copyleft implications)
- Are commercial licenses required?

#### **License Obligations**
- Attribution requirements
- Source disclosure requirements
- Modification disclosure requirements
- Patent grants or restrictions
- Trademark restrictions

#### **Compliance Documentation**
- Create SBOM (Software Bill of Materials)
- Document all licenses
- Ensure attribution files are included
- Verify license compatibility matrix

### 6. **Functionality & Necessity Review**

Evaluate if dependencies are actually needed:

#### **Functionality Analysis**
- What functionality does the dependency provide?
- Can it be implemented in-house with reasonable effort?
- Is only a small part of the library used?
- Are there lighter-weight alternatives?
- Can features be disabled to reduce attack surface?

#### **Alternatives Evaluation**
- Are there more secure alternatives?
- Are there better-maintained alternatives?
- Are there standard library alternatives?
- Can multiple dependencies be replaced with one?

#### **Minimization Strategy**
- Can optional features be disabled?
- Can the dependency be replaced with a smaller one?
- Can the functionality be inlined?
- Can weak dependencies (Rust) be avoided?

### 7. **Version Management Strategy**

Establish version management policy:

#### **Version Pinning**
**Rust (Cargo.toml):**
```toml
# Pinned exact version (most secure, but requires active updates)
serde = "=1.0.193"

# Compatible updates (patch level, generally safe)
serde = "~1.0.193"

# Minor version updates (requires review)
serde = "^1.0"
```

**C++ (CMakeLists.txt):**
```cmake
# Pinned version
find_package(OpenSSL 1.1.1 EXACT REQUIRED)

# Minimum version
find_package(OpenSSL 1.1.1 REQUIRED)
```

#### **Update Policy**
- How often are dependencies updated?
- Who reviews dependency updates?
- Are updates tested before merging?
- Is there a process for emergency patches?
- Are breaking changes reviewed?

#### **Lock Files**
- Is Cargo.lock or equivalent committed?
- Are CI builds reproducible?
- How are lock file updates managed?
- Is drift between environments prevented?

### 8. **Security Controls & Hardening**

Implement security controls:

#### **Dependency Scanning Automation**
- Run cargo-audit in CI
- Use dependency scanning tools
- Set up automated alerts
- Block PRs with high-severity vulns
- Regular scanning schedule

#### **Sandboxing & Isolation**
- Can dependencies run in isolated environments?
- Are network permissions restricted?
- Are file system permissions restricted?
- Can dependencies be containerized?
- Is privilege minimization applied?

#### **Build-Time Security**
- Are builds reproducible?
- Is dependency verification enabled (checksums)?
- Are build scripts (build.rs) reviewed?
- Are pre-built binaries avoided?
- Is compiler toolchain secured?

#### **Runtime Protections**
- Are sanitizers enabled for testing?
- Is fuzzing applied to code using dependencies?
- Are runtime bounds checks in place?
- Is defense-in-depth applied?

### 9. **Documentation**

Create dependency security audit report at `docs/security/dependency-audits/YYYY-MM-DD-audit.md`:

Include:
- Dependency inventory (all deps and versions)
- Vulnerability findings
- Risk assessment for each dependency
- Trustworthiness evaluation
- Supply chain risks identified
- License compliance status
- Recommendations (update, replace, remove)
- Action items with priorities
- Re-audit schedule

**Use template:** `./audit-template.md`

### 10. **Remediation & Ongoing Management**

Implement findings:

#### **Immediate Actions**
- Patch critical vulnerabilities
- Remove malicious or severely compromised dependencies
- Update dependencies with known exploits
- Disable vulnerable features

#### **Short-term Actions**
- Replace untrustworthy dependencies
- Update to secure versions
- Add dependency scanning to CI
- Document security policies

#### **Long-term Actions**
- Establish dependency review process
- Create secure dependency guidelines
- Regular audit schedule (quarterly/semi-annual)
- Vendor critical dependencies if necessary
- Contribute security fixes upstream

## C++/Rust Specific Considerations

### Rust Dependencies

**Advantages:**
- Strong type system reduces vulnerability impact
- cargo-audit integration with RustSec
- Memory safety by default (except unsafe)
- Active security community

**Risks:**
- Unsafe code in dependencies
- Build scripts (build.rs) can execute arbitrary code
- Proc-macros have full compiler access
- Smaller ecosystem means less scrutiny for some crates

**Best Practices:**
- Review unsafe code in critical dependencies
- Audit build scripts carefully
- Use cargo-crev for code reviews
- Check RustSec database regularly

### C++ Dependencies

**Advantages:**
- Mature ecosystem with established libraries
- Many libraries have decades of scrutiny
- Strong corporate backing for major libraries

**Risks:**
- Memory safety vulnerabilities common
- Build systems vary widely (CMake, Make, autotools)
- Pre-built binaries may have backdoors
- Transitive dependencies harder to track

**Best Practices:**
- Prefer header-only libraries when possible
- Build dependencies from source
- Use package managers with verification (vcpkg, Conan)
- Static analysis on dependency code
- Use modern, memory-safe C++ libraries

## Tools & Resources

### Rust Tools
- **cargo-audit**: Checks for vulnerabilities in Cargo.lock
- **cargo-crev**: Decentralized code review system
- **cargo-deny**: Linting for dependencies (licenses, vulnerabilities)
- **RustSec Advisory Database**: https://rustsec.org/

### C++ Tools
- **OWASP Dependency-Check**: Multi-language vulnerability scanning
- **vcpkg**: Package manager with security considerations
- **Conan**: C++ package manager
- **OSS-Fuzz**: Continuous fuzzing for open source projects

### General Tools
- **NVD**: National Vulnerability Database
- **OSV**: Open Source Vulnerabilities database
- **Snyk, WhiteSource, etc.**: Commercial dependency scanning
- **SBOM generators**: Creating software bill of materials

## Quality Checklist

Before completing audit, ensure:
- [ ] All dependencies inventoried
- [ ] Vulnerability scan completed
- [ ] Each dependency assessed for trustworthiness
- [ ] Supply chain risks evaluated
- [ ] Licenses checked for compliance
- [ ] Alternatives considered
- [ ] Version management strategy defined
- [ ] Security controls implemented
- [ ] Documentation complete
- [ ] Remediation plan with priorities
- [ ] Re-audit schedule established

## References

- OWASP Dependency-Check: https://owasp.org/www-project-dependency-check/
- NIST SSDF: https://csrc.nist.gov/Projects/ssdf
- RustSec: https://rustsec.org/
- cargo-audit: https://crates.io/crates/cargo-audit
- NVD: https://nvd.nist.gov/
- OSV: https://osv.dev/
- Audit Template: `./audit-template.md`

## Example Interaction

**User**: "We need to audit our dependencies before our security review next month"

**Your Response**:
1. Ask: Rust or C++ project? What files contain dependencies?
2. Read Cargo.toml or CMakeLists.txt
3. Run `cargo audit` (Rust) or check NVD for C++ deps
4. Create inventory of all dependencies (direct + transitive)
5. For each dependency:
   - Check for CVEs
   - Assess maintenance status (last commit, issue response)
   - Evaluate supply chain risk
   - Check license compatibility
   - Consider alternatives
6. Calculate risk scores:
   - Critical: Known RCE vulnerability, unmaintained
   - High: Known vuln, possible exploit, or supply chain risk
   - Medium: Unmaintained but no known vulns, or license concerns
   - Low: Well-maintained, no issues
7. Create recommendations:
   - Update: dependency-X from 1.0 to 1.2 (fixes CVE-2024-XXX)
   - Replace: dependency-Y with dependency-Z (better maintained)
   - Remove: dependency-A (unused feature)
8. Document findings in audit report
9. Suggest using specialized agents:
   - `vuln-assessment` for detailed CVE analysis
   - `review-security` for reviewing critical dependency code

## Important Notes

- **Trust but verify** - Even popular libraries can have vulnerabilities
- **Transitive dependencies matter** - They're part of your attack surface
- **Maintenance is key** - An unmaintained dependency is a ticking time bomb
- **License violations have consequences** - Take compliance seriously
- **Supply chain attacks are real** - Recent incidents show this is not theoretical
- **Minimize dependencies** - Every dependency is a risk
- **Audit regularly** - Security landscape changes constantly
- **Document everything** - Audits are useless if not documented
