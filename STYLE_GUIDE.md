\# Team Style Guide



\## 2.1 Naming Conventions

| Element | Convention | Example |

| :--- | :--- | :--- |

| Variables | camelCase | `thesisTitle` |

| Functions / Methods | camelCase | `getThesisById()` |

| Classes | PascalCase | `ThesisController` |

| Files | kebab-case/camelCase | `thesis-management.js` |

| Constants | UPPER CASE | `MAX\_UPLOAD\_SIZE` |

| Database tables / fields | snake\_case | `thesis\_documents` |



\## 2.2 Formatting Rules

| Rule | Team Decision |

| :--- | :--- |

| Indentation | 4 spaces |

| Line length limit | 100 characters |

| Brace style | K\&R style |

| Spaces vs. tabs | Spaces only |

| Blank lines between functions | 1 blank line |

| Max function length | 50 lines max |



\## 2.3 Commenting Standards

| Commenting Rule | Team Standard |

| :--- | :--- |

| File/module header comment | Required for every major file (e.g., ThesisController, UserController, Report module) explaining purpose and responsibilities |

| Function/method doc comment | Required using JSDoc-style or structured comments for key functions like approveThesis(), uploadDocument(), generateReport() |

| Inline comments (when to use) | Only for complex logic such as approval conditions, role validation, or file handling - avoid obvious comments |

| TODO comment format | `// TODO: <task description>` (used for pending features like enhancements in reports or UI improvements seen in video) |

| Language for comments | English only(ensures all group members understand, especially in collaborative development) |



\## 2.4 Branch Naming Strategy

| Branch Type | Naming Format | Example |

| :--- | :--- | :--- |

| Feature branch | `feature/<module>-<action>` | `feature/thesis-upload`, `feature/user-management` |

| Bug fix branch | `fix/<module>-<issue>` | `fix/login-validation`, `fix/file-upload-error` |

| Hotfix branch | `hotfix/<critical-issue>` | `hotfix/security-auth-bypass` |

| Release branch | `release/<version>` | `release/v1.0` |

