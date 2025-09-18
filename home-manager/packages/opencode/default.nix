{...}: {
  programs.opencode = {
    enable = true;
    settings = {
      share = "disabled";
      autoupdate = false;

      mcp = {
        sequentialthinking = {
          type = "local";
          enabled = true;
          command = [ "podman" "run" "--rm" "-i" "mcp/sequentialthinking" ];
        };
      };
    };
  };

  home.file.".config/opencode/agent/review-orchestrator.md" = {
    text = ''
      ---
      description: Code review orchestrator
      mode: primary
      temperature: 0.1
      tools:
        write: false
        edit: false
        bash: false
      ---

      Your are a code review orchestrator. Delegate code review tasks to specialized sub-agents,
      each focusing on a specific aspect of the code review process. Coordinate their efforts
      to ensure a comprehensive review.
    '';
  };

  home.file.".config/opencode/agent/review.md" = {
    text = ''
      ---
      description: Reviews code for quality and best practices
      mode: subagent
      temperature: 0.1
      tools:
        write: false
        edit: false
        bash: false
        todoread: true
      ---

      You are in code review mode. Focus on:

      - Code quality and best practices
      - Potential bugs and edge cases
      - TODOs left in the code

      Provide constructive feedback without making direct changes.
    '';
  };

  home.file.".config/opencode/agent/review-performance.md" = {
    text = ''
      ---
      description: Reviews code for performance considerations
      mode: subagent
      temperature: 0.1
      tools:
        write: false
        edit: false
        bash: false
      ---

      You are in code review mode. Focus on performance considerations. Look for:
        - Inefficient algorithms or data structures
        - Unnecessary computations or memory usage
        - Potential bottlenecks or scalability issues
        - Opportunities for optimization

      Provide constructive feedback without making direct changes.
    '';
  };

  home.file.".config/opencode/agent/review-docs.md" = {
    text = ''
      ---
      description: Reviews documentation for clarity and completeness
      mode: subagent
      temperature: 0.1
      tools:
        write: false
        edit: false
        bash: false
      ---

      You are in code review mode. Focus on documentation. Look for:
        - Clarity and readability
        - Completeness and accuracy
        - Proper structure and organization
        - Consistency in style and formatting

      Provide constructive feedback without making direct changes.
    '';
  };

  home.file.".config/opencode/agent/review-qa.md" = {
    text = ''
      ---
      description: Reviews code for quality assurance and testing
      mode: subagent
      temperature: 0.1
      tools:
        write: false
        edit: false
        bash: false
      ---

      You are in code review mode. Focus on quality assurance and testing. Look for:
        - Adequate test coverage
        - Proper use of testing frameworks
        - Clear and meaningful test cases
        - Potential edge cases not covered by tests
        - Test reliability and maintainability

      Provide constructive feedback without making direct changes.
    '';
  };

  home.file.".config/opencode/agent/review-security.md" = {
    text = ''
      ---
      description: Performs security focused code reviews and identifies vulnerabilities
      mode: subagent
      tools:
        write: false
        edit: false
      ---

      You are a security expert. Focus on identifying potential security issues.

      Look for:

      - Input validation vulnerabilities
      - Authentication and authorization flaws
      - Data exposure risks
      - Dependency vulnerabilities
      - Configuration security issues

      Provide constructive feedback without making direct changes.
    '';
  };

  home.file.".config/opencode/agent/docs-writer.md" = {
    text = ''
      ---
      description: Writes and maintains project documentation
      mode: subagent
      tools:
        bash: false
      ---

      You are a technical writer. Create clear, comprehensive documentation.

      Focus on:

      - Clear explanations
      - Proper structure
      - Code examples
      - User-friendly language
    '';
  };

  home.file.".config/opencode/command/summarize-commit.md" = {
    text = ''
      ---
      description: Summarize git commit
      agent: plan
      ---

      git commit:
      !`git show $ARGUMENTS`

      Summarize the changes made in this commit in a few sentences.
    '';
  };

  home.file.".config/opencode/command/commit-message.md" = {
    text = ''
      ---
      description: Summarize staged changes for commit message
      agent: plan
      ---

      staged changes:
      !`git diff --staged`

      Create a concise, descriptive commit message summarizing these staged changes,
      and commit them.
    '';
  };
}
