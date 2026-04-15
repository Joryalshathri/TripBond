import 'package:flutter/material.dart';

class BondersSuggestions extends StatefulWidget {
  final List<Map<String, dynamic>> suggestions;
  final String? source;

  const BondersSuggestions({
    super.key,
    required this.suggestions,
    this.source = 'home',
  });

  @override
  State<BondersSuggestions> createState() => _BondersSuggestionsState();
}

class _BondersSuggestionsState extends State<BondersSuggestions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bonders Suggestions',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: const [
                Text('Action',
                    style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14)),
                SizedBox(width: 40),
                Text('Course',
                    style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14)),
                Spacer(),
                Icon(Icons.filter_list, color: Color(0xFF9E9E9E), size: 20),
              ],
            ),
          ),
          Expanded(
            child: widget.suggestions.isEmpty
                ? Center(
                    child: Text(
                      'No suggestions yet',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: widget.suggestions.length,
                    itemBuilder: (context, i) {
                      final s = widget.suggestions[i];
                      final isHighlight = s['highlight'] as bool;
                      final isAdd = s['action'] == 'add';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 60,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(isAdd ? 'Add' : 'Delete',
                                      style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          color: Colors.grey.shade500)),
                                  Icon(
                                      isAdd
                                          ? Icons.add_circle_outline
                                          : Icons.delete_outline,
                                      size: 24,
                                      color: Colors.grey.shade600),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isHighlight
                                      ? const Color(0xFFE8D5A0)
                                      : Colors.white,
                                  border: Border.all(
                                      color: isHighlight
                                          ? const Color(0xFFD4BC7A)
                                          : Colors.grey.shade200),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(s['name'] as String,
                                            style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                                color: isHighlight
                                                    ? Colors.white
                                                    : Colors.black)),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.favorite_border,
                                                size: 18,
                                                color: isHighlight
                                                    ? Colors.white
                                                    : const Color(0xFFC4A44A)),
                                            const SizedBox(width: 12),
                                            Icon(Icons.close,
                                                size: 18,
                                                color: isHighlight
                                                    ? Colors.white
                                                    : const Color(0xFF1E1E1E)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Text(s['type'] as String,
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 13,
                                            color: isHighlight
                                                ? Colors.white70
                                                : Colors.grey.shade500)),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on,
                                            size: 12,
                                            color: isHighlight
                                                ? Colors.white
                                                : const Color(0xFF4675B8)),
                                        const SizedBox(width: 4),
                                        Text(s['location'] as String,
                                            style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 12,
                                                color: isHighlight
                                                    ? Colors.white70
                                                    : Colors.grey.shade500)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        CircleAvatar(
                                            radius: 8,
                                            backgroundColor:
                                                s['personColor'] as Color,
                                            child: Text(
                                                (s['person'] as String)[0],
                                                style: const TextStyle(
                                                    fontSize: 8,
                                                    color: Colors.white))),
                                        const SizedBox(width: 4),
                                        Text(s['person'] as String,
                                            style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 12,
                                                color: isHighlight
                                                    ? Colors.white70
                                                    : Colors.grey.shade500)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
