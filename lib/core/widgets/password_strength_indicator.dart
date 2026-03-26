import 'package:flutter/material.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final bool hasLength = password.length >= 8;
    final bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final bool hasNumber = password.contains(RegExp(r'[0-9]'));
    final bool hasSpecial = password.contains(
      RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
    );

    int strength = 0;
    if (password.isNotEmpty) {
      if (!hasLength) {
        strength = 1; // Very weak
      } else {
        int categoriesMet = 0;
        if (hasUppercase) categoriesMet++;
        if (hasNumber) categoriesMet++;
        if (hasSpecial) categoriesMet++;

        if (categoriesMet <= 1) {
          strength = 2; // Weak
        } else if (categoriesMet == 2) {
          strength = 3; // Medium
        } else if (categoriesMet == 3) {
          strength = 4; // Strong
        }
      }
    }

    Color strengthColor;
    String strengthText;
    switch (strength) {
      case 1:
        strengthColor = Colors.red;
        strengthText = 'Very Weak';
        break;
      case 2:
        strengthColor = Colors.orange;
        strengthText = 'Weak';
        break;
      case 3:
        strengthColor = Colors.yellow[700]!;
        strengthText = 'Medium';
        break;
      case 4:
        strengthColor = Colors.green;
        strengthText = 'Strong';
        break;
      default:
        strengthColor = Colors.grey[300]!;
        strengthText = '';
    }

    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: List.generate(4, (index) {
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index < 3 ? 4 : 0),
                decoration: BoxDecoration(
                  color: index < strength ? strengthColor : Colors.grey[200],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        if (strengthText.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            strengthText,
            style: TextStyle(
              color: strengthColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}
