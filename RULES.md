# RULES

Version: 1.0

These rules are mandatory for every contributor, automation tool, and AI coding agent.

Breaking these rules requires explicit approval.

---

# 1. Core Principles

Always prioritize:

1. Stability
2. Simplicity
3. Maintainability
4. Performance
5. Security

Never optimize one objective by severely harming another.

---

# 2. Suckless Philosophy

The project follows the Suckless philosophy.

Prefer

* Simple solutions
* Small programs
* Standard UNIX tools
* Clear configuration
* Explicit behavior

Avoid

* Hidden behavior
* Over-engineering
* Frameworks
* Unnecessary abstraction

---

# 3. Keep It Minimal

Never install software that is not used.

Every package must have a clear purpose.

Every dependency must be justified.

Unused software must be removed.

---

# 4. Terminal First

Every task should be possible from the terminal.

GUI tools are allowed only when they provide significant practical value.

GUI applications must never replace existing CLI workflows without justification.

---

# 5. Wayland Only

The project targets Wayland.

Do not introduce X11 dependencies unless absolutely required.

If an application supports native Wayland, prefer the Wayland backend.

---

# 6. OpenRC Only

The init system is OpenRC.

Never introduce systemd services.

Prefer native OpenRC service scripts whenever possible.

---

# 7. Reproducibility

Every installation must produce the same result.

Scripts must not depend on undocumented user interaction.

Random behavior is prohibited.

---

# 8. Idempotency

Every installation script must be safe to execute multiple times.

Running a script twice must not break the system.

Scripts must detect existing resources before creating or modifying them.

---

# 9. Documentation First

Every non-trivial configuration requires documentation.

Every optimization must explain:

* what changed
* why it changed
* expected benefit
* possible drawbacks

---

# 10. Source of Truth

Configuration files stored in this repository are the authoritative source.

Generated files must never be edited manually.

---

# 11. Comments

Configuration files should contain useful comments.

Do not explain obvious syntax.

Explain intent.

---

# 12. Performance

Optimize only when measurable.

Avoid premature optimization.

Every optimization should have a measurable benefit.

---

# 13. Resource Usage

Keep idle resource usage low.

Avoid unnecessary daemons.

Avoid unnecessary polling.

Prefer event-driven behavior.

---

# 14. Security

Secure defaults are required.

Never disable security features for convenience.

Least privilege should be the default.

---

# 15. Boot Reliability

The system must remain bootable.

Kernel updates must never remove the fallback kernel.

Bootloader configuration must always be validated.

---

# 16. Filesystem Safety

Never perform destructive Btrfs operations automatically.

Snapshots must be created before risky operations.

Rollback must remain possible.

---

# 17. Package Selection

Choose packages using the following priority:

1. Official repositories
2. Well-maintained community packages
3. Build from source
4. Custom patches

Avoid abandoned software.

---

# 18. Build From Source

Source builds are preferred only when one of the following is true:

* Suckless software
* Patch required
* Performance benefit
* Repository version is outdated

Otherwise use packaged software.

---

# 19. Community Patches

Community patches are allowed only when they are:

* Stable
* Maintained
* Widely used
* Small
* Easy to review
* Easy to remove

Experimental patches are prohibited.

---

# 20. Shell Scripts

All shell scripts must:

* use Bash
* enable strict mode where appropriate
* validate input
* return proper exit codes
* produce meaningful error messages
* avoid duplicated code

---

# 21. Logging

Every installation script must create logs.

Errors must be easy to identify.

Log output should remain readable.

---

# 22. Error Handling

Never ignore command failures.

Every critical operation must be verified.

Exit immediately on unrecoverable errors.

---

# 23. Configuration Style

Configuration should be:

* explicit
* readable
* consistent
* documented

Magic values should be avoided.

---

# 24. Naming

Use descriptive names.

Avoid abbreviations unless universally understood.

Keep naming consistent across the repository.

---

# 25. Repository Layout

Each directory has a single responsibility.

Avoid dumping unrelated files into one location.

---

# 26. AI Agent Behavior

Before changing anything, an AI agent must:

1. Read README.md
2. Read SPEC.md
3. Read RULES.md
4. Read STYLE_GUIDE.md
5. Read TASKS.md

Skipping these steps is not allowed.

---

# 27. AI Output

AI-generated code must:

* compile
* run
* be documented
* be deterministic
* follow repository conventions

Placeholder implementations are not acceptable unless explicitly requested.

---

# 28. Review Checklist

Before considering a task complete, verify:

* Documentation updated
* Configuration validated
* Scripts tested
* No duplicate packages
* No conflicting services
* No unnecessary dependencies
* No performance regression
* No security regression

---

# 29. Change Management

Large changes should be divided into smaller commits.

Each commit should represent one logical change.

Commit messages should clearly describe the intent.

---

# 30. Long-Term Maintenance

Every decision should consider future maintenance.

Choose boring, reliable solutions over clever but fragile ones.

The repository should remain understandable to a new contributor years later.

---

# Final Rule

If a proposed change conflicts with these rules, the change must be rejected unless the project specification is intentionally updated first.
