# Contributing to WhatsApp Photo Backup

We welcome contributions! This document outlines the process for contributing to this project.

## Getting Started

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests and verification:
   ```bash
   scripts/verify-swift-code.sh
   scripts/build-ios.sh
   ```
5. Commit with clear messages
6. Push to your branch
7. Open a Pull Request

## Code Style

- Follow Swift style guidelines
- Use meaningful variable and function names
- Add comments for complex logic only
- Keep functions small and focused
- Use proper error handling

## Testing

- Write tests for new features
- Ensure all tests pass before submitting
- Aim for > 80% code coverage
- Test error scenarios

## Documentation

- Update README for new features
- Add documentation to public APIs
- Include examples for complex features
- Keep docs in sync with code

## Commit Messages

Use clear, descriptive commit messages:
```
Brief summary (50 chars max)

More detailed explanation if needed, wrapped at 72 characters.
Explain why the change is needed, not what it does.
```

## Pull Request Process

1. Update documentation
2. Add tests for new features
3. Ensure CI passes
4. Request review from maintainers
5. Address feedback
6. Merge only after approval

## Issues

- Use clear titles
- Provide reproduction steps
- Include device/OS information
- Attach screenshots if relevant

## Code of Conduct

- Be respectful and constructive
- Assume good intent
- Focus on the code, not the person
- Welcome diverse perspectives

## Questions?

Open an issue or discussion for questions.

Thank you for contributing! 🎉
