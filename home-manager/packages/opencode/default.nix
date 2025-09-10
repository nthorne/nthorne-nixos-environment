{...}: {
  programs.opencode = {
    enable = true;
    settings = {
      share = "disabled";
      autoupdate = false;
    };
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
      ---

      You are in code review mode. Focus on:

      - Code quality and best practices
      - Potential bugs and edge cases
      - Performance implications
      - Security considerations

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

  home.file.".config/opencode/agent/security-auditor.md" = {
    text = ''
      ---
      description: Performs security audits and identifies vulnerabilities
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
