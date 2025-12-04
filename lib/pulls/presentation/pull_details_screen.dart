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

  // Controladores para el Chat
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late Pull _currentPull;
  bool _isLoading = false;
  bool _isPriceEditing = false;

  // Lista de mensajes (Hardcoded inicial)
  // NOTA: La lista se visualiza con reverse: true, por lo que el índice 0 es el mensaje más abajo (el último)
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _currentPull = widget.pull;
    _priceController.text = _currentPull.priceUpdate.toStringAsFixed(1);

    // Inicializar mensajes hardcodeados según requerimiento:
    // David Wayne (You) -> Derecha / Azul
    // Juan Torres -> Izquierda / Gris
    _messages = [
      // Último mensaje (aparece abajo) - De Juan Torres
      ChatMessage(
        text: "Great! 😉",
        isMe: false, // Izquierda
        sender: "Juan Torres",
        time: "10:20",
      ),
      // Mensaje del medio - De David Wayne
      ChatMessage(
        text: "Oh!\nThey fixed it and upgraded the security further. 🚀",
        isMe: true, // Derecha (You)
        sender: "David Wayne",
        time: "10:14",
      ),
      // Primer mensaje (aparece arriba) - De David Wayne
      ChatMessage(
        text: "Does this update fix error 352 for the Engineer character?",
        isMe: true, // Derecha (You)
        sender: "David Wayne",
        time: "10:11",
      ),
    ];
  }

  @override
  void dispose() {
    _priceController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = ChatMessage(
      text: _messageController.text.trim(),
      isMe: true, // Los nuevos mensajes son "Míos" (David Wayne)
      sender: "David Wayne",
      time: "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
    );

    setState(() {
      _messages.insert(0, newMessage); // Insertar al inicio porque la lista está invertida
    });

    _messageController.clear();
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

            // SECCIÓN DE CHAT IMPLEMENTADA
            Container(
              color: Colors.white,
              // Le damos una altura fija para simular un widget de chat
              // o puedes usar un SizedBox.
              height: 500,
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 0),
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

                  // LISTA DE MENSAJES
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      reverse: true, // Los mensajes nuevos van abajo
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        return _buildMessageBubble(msg);
                      },
                    ),
                  ),

                  // INPUT DE TEXTO
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.add, color: const Color(0xFF1E3A5F), size: 28),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _messageController,
                                    decoration: const InputDecoration(
                                      hintText: 'Type a message...',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      isDense: true,
                                    ),
                                    textCapitalization: TextCapitalization.sentences,
                                    onSubmitted: (_) => _sendMessage(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: _sendMessage,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1E3A5F),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.send, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
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

  Widget _buildMessageBubble(ChatMessage msg) {
    // Definir colores y alineación según si "soy yo" (David Wayne) o "el otro" (Juan Torres)
    final isMe = msg.isMe;

    // Configuración según el requerimiento:
    // David Wayne (isMe = true) -> Derecha, Azul
    // Juan Torres (isMe = false) -> Izquierda, Gris
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bgColor = isMe ? const Color(0xFF1E3A5F) : Colors.white; // Azul vs Blanco
    final textColor = isMe ? Colors.white : Colors.black87;
    final initial = isMe ? "D" : "J"; // David vs Juan

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: align,
        children: [
          // Nombre del remitente
          if (!isMe) ...[
            Padding(
              padding: const EdgeInsets.only(left: 48, bottom: 4),
              child: Text(
                msg.sender,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
          ],

          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar solo para el "otro" (Izquierda)
              if (!isMe)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[500],
                    child: Text(initial, style: const TextStyle(color: Colors.white)),
                  ),
                ),

              // Burbuja del mensaje
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
                      bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
                    ),
                    boxShadow: [
                      if (!isMe)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.text,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        msg.time,
                        style: TextStyle(
                          color: isMe ? Colors.white70 : Colors.grey[400],
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
              ),

              // Avatar para "mi" (Opcional, usualmente no se pone, pero si quisieras a la derecha)
              if (isMe)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blueAccent,
                    child: Text(initial, style: const TextStyle(color: Colors.white)),
                  ),
                ),
            ],
          ),
        ],
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

// Clase Modelo para el mensaje
class ChatMessage {
  final String text;
  final bool isMe; // true = David Wayne (Derecha), false = Juan Torres (Izquierda)
  final String sender;
  final String time;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.sender,
    required this.time,
  });
}