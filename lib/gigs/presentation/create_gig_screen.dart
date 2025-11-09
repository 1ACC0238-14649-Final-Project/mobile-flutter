import 'package:flutter/material.dart';
import 'gig_payment_screen.dart';

class CreateGigScreen extends StatefulWidget {
  final VoidCallback? onGigCreated;
  final VoidCallback? onBack;

  const CreateGigScreen({
    super.key,
    this.onGigCreated,
    this.onBack,
  });

  @override
  State<CreateGigScreen> createState() => _CreateGigScreenState();
}

class _CreateGigScreenState extends State<CreateGigScreen> {
  final titleCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();
  final tagsCtrl = TextEditingController();
  final imageCtrl = TextEditingController();

  String? selectedImageUrl;
  String? errorMessage;

  void _goToNextStep() {
    if (titleCtrl.text.trim().isEmpty) {
      setState(() => errorMessage = 'El título es requerido');
      return;
    }
    if (descriptionCtrl.text.trim().isEmpty) {
      setState(() => errorMessage = 'La descripción es requerida');
      return;
    }

    // Parsear tags separados por comas
    final tags = tagsCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // Navegar a la pantalla de pago
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GigPaymentScreen(
          title: titleCtrl.text.trim(),
          description: descriptionCtrl.text.trim(),
          category: categoryCtrl.text.trim().isEmpty ? null : categoryCtrl.text.trim(),
          image: imageCtrl.text.trim().isEmpty ? null : imageCtrl.text.trim(),
          tags: tags,
          onGigCreated: widget.onGigCreated,
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descriptionCtrl.dispose();
    categoryCtrl.dispose();
    tagsCtrl.dispose();
    imageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'New Gig',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.normal,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A5F), // Azul oscuro
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: widget.onBack,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Upload Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (imageCtrl.text.trim().isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageCtrl.text.trim(),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image),
                            ),
                          ),
                        )
                      else
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.image, size: 40),
                        ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'UPLOAD IMAGE',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ingresa la URL de la imagen',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Field
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() => errorMessage = null),
              ),
              const SizedBox(height: 12),

              // Description Field
              TextField(
                controller: descriptionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                onChanged: (_) => setState(() => errorMessage = null),
              ),
              const SizedBox(height: 12),

              // Category Field
              TextField(
                controller: categoryCtrl,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                  hintText: 'Selecciona o ingresa una categoría',
                ),
              ),
              const SizedBox(height: 12),

              // Tags Field
              TextField(
                controller: tagsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tags',
                  border: OutlineInputBorder(),
                  hintText: 'Tags: UX Design, Web Dev',
                  helperText: 'Separa los tags con comas',
                ),
              ),
              const SizedBox(height: 12),

              // Image URL Field (hidden by default, shown if needed)
              TextField(
                controller: imageCtrl,
                decoration: const InputDecoration(
                  labelText: 'Image URL (opcional)',
                  border: OutlineInputBorder(),
                  helperText: 'URL de la imagen o base64',
                ),
                keyboardType: TextInputType.url,
                onChanged: (value) {
                  setState(() {
                    selectedImageUrl = value.trim().isNotEmpty ? value.trim() : null;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Error Message
              if (errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Next Step Button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _goToNextStep,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Next Step'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

