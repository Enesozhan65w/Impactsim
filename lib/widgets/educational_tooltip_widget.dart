import 'package:flutter/material.dart';

/// Eğitim modu için tooltip widget'ı
/// Teknik terimlerin açıklamalarını gösterir
class EducationalTooltip extends StatelessWidget {
  final String message;
  final Widget child;
  final bool enabled;

  const EducationalTooltip({
    super.key,
    required this.message,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    
    return Tooltip(
      message: message,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      preferBelow: false,
      child: child,
    );
  }
}

/// Eğitim kartı widget'ı - detaylı açıklamalar için
class EducationalCard extends StatefulWidget {
  final String title;
  final String description;
  final String? detailedExplanation;
  final IconData icon;
  final Color iconColor;
  final List<String>? keyPoints;
  final Widget? child;

  const EducationalCard({
    super.key,
    required this.title,
    required this.description,
    this.detailedExplanation,
    required this.icon,
    this.iconColor = Colors.orange,
    this.keyPoints,
    this.child,
  });

  @override
  State<EducationalCard> createState() => _EducationalCardState();
}

class _EducationalCardState extends State<EducationalCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1F3A),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          ListTile(
            leading: Icon(widget.icon, color: widget.iconColor),
            title: Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              widget.description,
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: widget.detailedExplanation != null || widget.keyPoints != null
                ? IconButton(
                    icon: AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(Icons.expand_more, color: Colors.white60),
                    ),
                    onPressed: _toggleExpanded,
                  )
                : null,
          ),
          if (widget.child != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: widget.child!,
            ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF0F1419),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.detailedExplanation != null) ...[
                    const Text(
                      'Detaylı Açıklama:',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.detailedExplanation!,
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                  ],
                  if (widget.keyPoints != null) ...[
                    if (widget.detailedExplanation != null) const SizedBox(height: 16),
                    const Text(
                      'Önemli Noktalar:',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...widget.keyPoints!.map((point) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '• ',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  point,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Eğitim modu için özel terim açıklama widget'ı
class TechnicalTermWidget extends StatelessWidget {
  final String term;
  final String definition;
  final String? example;
  final Color? color;

  const TechnicalTermWidget({
    super.key,
    required this.term,
    required this.definition,
    this.example,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (color ?? Colors.orange).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (color ?? Colors.orange).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            term,
            style: TextStyle(
              color: color ?? Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            definition,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          if (example != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: Colors.yellow.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Örnek: $example',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Eğitim modu için interaktif quiz widget'ı
class EducationalQuiz extends StatefulWidget {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  const EducationalQuiz({
    super.key,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });

  @override
  State<EducationalQuiz> createState() => _EducationalQuizState();
}

class _EducationalQuizState extends State<EducationalQuiz> {
  int? _selectedAnswer;
  bool _showResult = false;

  void _selectAnswer(int index) {
    setState(() {
      _selectedAnswer = index;
      _showResult = true;
    });
  }

  void _resetQuiz() {
    setState(() {
      _selectedAnswer = null;
      _showResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1F3A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.quiz, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Eğitim Sorusu',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.question,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ...widget.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isSelected = _selectedAnswer == index;
              final isCorrect = index == widget.correctAnswerIndex;
              
              Color? backgroundColor;
              Color? borderColor;
              
              if (_showResult) {
                if (isCorrect) {
                  backgroundColor = Colors.green.withOpacity(0.2);
                  borderColor = Colors.green;
                } else if (isSelected && !isCorrect) {
                  backgroundColor = Colors.red.withOpacity(0.2);
                  borderColor = Colors.red;
                }
              } else if (isSelected) {
                backgroundColor = Colors.orange.withOpacity(0.2);
                borderColor = Colors.orange;
              }
              
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: InkWell(
                  onTap: _showResult ? null : () => _selectAnswer(index),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: borderColor ?? Colors.white12,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: borderColor?.withOpacity(0.3),
                            border: Border.all(
                              color: borderColor ?? Colors.white30,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + index), // A, B, C, D
                              style: TextStyle(
                                color: borderColor ?? Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            option,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (_showResult && isCorrect)
                          const Icon(Icons.check, color: Colors.green),
                        if (_showResult && isSelected && !isCorrect)
                          const Icon(Icons.close, color: Colors.red),
                      ],
                    ),
                  ),
                ),
              );
            }),
            if (_showResult) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _selectedAnswer == widget.correctAnswerIndex
                              ? Icons.check_circle
                              : Icons.info,
                          color: _selectedAnswer == widget.correctAnswerIndex
                              ? Colors.green
                              : Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedAnswer == widget.correctAnswerIndex
                              ? 'Doğru!'
                              : 'Açıklama:',
                          style: TextStyle(
                            color: _selectedAnswer == widget.correctAnswerIndex
                                ? Colors.green
                                : Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.explanation,
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _resetQuiz,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tekrar Dene'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
