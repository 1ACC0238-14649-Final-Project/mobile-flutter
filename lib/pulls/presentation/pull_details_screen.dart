import 'package:flutter/material.dart';
import '../domain/model/pull.dart';
import '../data/repository/pull_repository.dart';
import '../../gigs/domain/model/gig.dart';
import 'dart:developer' as developer;

class PullDetailsScreen extends StatefulWidget {
  final Pull pull;
  final Gig? gig;

  const PullDetailsScreen({
    super.key,
    required this.pull,
    this.gig,
  });

  @override
  State<PullDetailsScreen> createState() => _PullDetailsScreenState();
}

class _PullDetailsScreenState extends State<PullDetailsScreen> {
  final _pullRepository = PullRepository();
  final _priceController = TextEditingController();

  late Pull _currentPull;
  bool _isLoading = false;
  bool _isPriceEditing = false;

  @override
  void initState() {
    super.initState();
    _currentPull = widget.pull;
    _priceController.text = _currentPull.priceUpdate.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _updatePrice() async {
    final newPrice = double.tryParse(_priceController.text);
    if (newPrice == null || newPrice <= 0) {
      _showErrorDialog('Por favor ingresa un precio válido');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedPull = await _pullRepository.updatePullPrice(_currentPull.id, newPrice);

      setState(() {
        _currentPull = updatedPull;
        _isPriceEditing = false;
        _isLoading = false;
      });

      _showSuccessSnackBar('Precio actualizado correctamente');
    } catch (e) {
      developer.log('Error updating price', name: 'PullDetailsScreen', error: e);
      setState(() => _isLoading = false);
      _showErrorDialog('Error al actualizar precio: $e');
    }
  }

  Future<void> _cancelPull() async {
    final confirmed = await _showConfirmDialog(
      'Cancelar Pull',
      '¿Estás seguro que quieres cancelar este pull?',
    );

    if (!confirmed) return;

    setState(() => _isLoading = true);

    try {
      final updatedPull = await _pullRepository.updatePullState(_currentPull.id, 'canceled');

      setState(() {
        _currentPull = updatedPull;
        _isLoading = false;
      });

      _showSuccessSnackBar('Pull cancelado');
    } catch (e) {
      developer.log('Error canceling pull', name: 'PullDetailsScreen', error: e);
      setState(() => _isLoading = false);
      _showErrorDialog('Error al cancelar pull: $e');
    }
  }

  Future<void> _acceptPull() async {
    final confirmed = await _showConfirmDialog(
      'Aceptar Pull',
      '¿Estás seguro que quieres aceptar este pull y comenzar a trabajar?',
    );

    if (!confirmed) return;

    setState(() => _isLoading = true);

    try {
      final updatedPull = await _pullRepository.updatePullState(_currentPull.id, 'in_process');

      setState(() {
        _currentPull = updatedPull;
        _isLoading = false;
      });

      _showSuccessSnackBar('Pull aceptado! Trabajo iniciado.');
    } catch (e) {
      developer.log('Error accepting pull', name: 'PullDetailsScreen', error: e);
      setState(() => _isLoading = false);
      _showErrorDialog('Error al aceptar pull: $e');
    }
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A5F),
              foregroundColor: Colors.white,
            ),
            child: const Text('Sí'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pull Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E3A5F),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Initial',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$${_currentPull.priceInit.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 24),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Actual',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            _isPriceEditing
                                ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF1E3A5F),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextField(
                                controller: _priceController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  prefix: Text(
                                    '\$ ',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E3A5F),
                                    ),
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E3A5F),
                                ),
                              ),
                            )
                                : Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '\$${_currentPull.priceUpdate.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E3A5F),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  if (_currentPull.state == PullState.pending) ...[
                    if (_isPriceEditing)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isPriceEditing = false;
                                _priceController.text = _currentPull.priceUpdate.toStringAsFixed(1);
                              });
                            },
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _updatePrice,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              'Guardar',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      )
                    else
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() => _isPriceEditing = true);
                          },
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text(
                            'Editar precio',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF1E3A5F),
                          ),
                        ),
                      ),

                    const SizedBox(height: 32),

                    const Text(
                      '¿Desea aceptar el pull?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _cancelPull,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1E3A5F),
                              side: const BorderSide(
                                color: Color(0xFF1E3A5F),
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: _acceptPull,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A5F),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Accept',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.all(16),
              child: _buildGigInfo(),
            ),

            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chat',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Chat functionality coming soon...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGigInfo() {
    final gig = widget.gig;
    final gigImage = gig?.image;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 100,
              height: 100,
              color: Colors.grey[300],
              child: (gigImage != null && gigImage.isNotEmpty)
                  ? Image.network(
                gigImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.image_not_supported,
                    size: 40,
                    color: Colors.grey[600],
                  );
                },
              )
                  : Icon(
                Icons.work_outline,
                size: 40,
                color: Colors.grey[600],
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gig?.title ?? 'Gig #${_currentPull.gigId}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${_currentPull.priceUpdate.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}