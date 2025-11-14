import 'package:flutter/material.dart';
import '../data/repository/pull_repository.dart';
import '../domain/model/pull.dart';
import '../../gigs/data/repository/gig_repository.dart';
import '../../gigs/domain/model/gig.dart';
import 'dart:developer' as developer;

class MyPullsScreen extends StatefulWidget {
  const MyPullsScreen({super.key});

  @override
  State<MyPullsScreen> createState() => _MyPullsScreenState();
}

class _MyPullsScreenState extends State<MyPullsScreen> {
  final _pullRepository = PullRepository();
  final _gigRepository = GigRepository();
  List<Pull> _pulls = [];
  Map<int, Gig> _gigsCache = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPulls();
  }

  Future<void> _loadPulls() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      developer.log('🔄 Iniciando carga de pulls para seller...', name: 'MyPullsScreen');
      final pulls = await _pullRepository.getPullsBySellerId();
      developer.log('📦 Pulls recibidos: ${pulls.length}', name: 'MyPullsScreen');

      // Cargar información de los gigs para cada pull
      final gigsCache = <int, Gig>{};
      for (final pull in pulls) {
        try {
          developer.log('📥 Cargando gig ${pull.gigId} para pull ${pull.id}...', name: 'MyPullsScreen');
          final gig = await _gigRepository.getGigById(pull.gigId.toString());
          gigsCache[pull.gigId] = gig;
          developer.log('✅ Gig ${pull.gigId} cargado: ${gig.title}', name: 'MyPullsScreen');
        } catch (e) {
          developer.log('⚠️ Error loading gig ${pull.gigId}: $e', name: 'MyPullsScreen', error: e);
        }
      }

      developer.log('✅ Carga completada. Pulls: ${pulls.length}, Gigs cargados: ${gigsCache.length}', name: 'MyPullsScreen');
      setState(() {
        _pulls = pulls;
        _gigsCache = gigsCache;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      developer.log('❌ Error al cargar pulls', name: 'MyPullsScreen', error: e, stackTrace: stackTrace);
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getStateText(PullState state) {
    switch (state) {
      case PullState.pending:
        return 'Pendiente';
      case PullState.inProcess:
        return 'En Proceso';
      case PullState.complete:
        return 'Completado';
      case PullState.canceled:
        return 'Cancelado';
    }
  }

  Color _getStateColor(PullState state) {
    switch (state) {
      case PullState.pending:
        return Colors.orange;
      case PullState.inProcess:
        return Colors.blue;
      case PullState.complete:
        return Colors.green;
      case PullState.canceled:
        return Colors.red;
    }
  }

  IconData _getStateIcon(PullState state) {
    switch (state) {
      case PullState.pending:
        return Icons.schedule;
      case PullState.inProcess:
        return Icons.construction;
      case PullState.complete:
        return Icons.check_circle;
      case PullState.canceled:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Pulls',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.normal,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A5F),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadPulls,
          ),
        ],
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPulls,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      )
          : _pulls.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay pulls disponibles',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Los pulls aparecerán aquí',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadPulls,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const SizedBox(height: 24),
              // Grid de 2 columnas
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: _pulls.length,
                itemBuilder: (context, index) {
                  final pull = _pulls[index];
                  final gig = _gigsCache[pull.gigId];

                  return _buildPullCard(pull, gig);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPullCard(Pull pull, Gig? gig) {
    final gigImage = gig?.image;
    final gigCategory = gig?.category;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Imagen del gig
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 100,
              width: double.infinity,
              color: Colors.grey[300],
              child: (gigImage != null && gigImage.isNotEmpty)
                  ? Image.network(
                gigImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: Colors.grey[600],
                    ),
                  );
                },
              )
                  : Container(
                color: Colors.grey[300],
                child: Icon(
                  Icons.image_not_supported,
                  size: 48,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),

          // Contenido del card
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Estado del pull con icono
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _getStateColor(pull.state).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _getStateColor(pull.state).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStateIcon(pull.state),
                        size: 10,
                        color: _getStateColor(pull.state),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _getStateText(pull.state),
                        style: TextStyle(
                          color: _getStateColor(pull.state),
                          fontWeight: FontWeight.w600,
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // Título del gig
                Text(
                  gig?.title ?? 'Gig #${pull.gigId}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 2),

                // Descripción del gig
                if (gig != null && gig.description.isNotEmpty)
                  Text(
                    gig.description,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                const SizedBox(height: 4),

                // Categoría y precio
                Builder(
                  builder: (context) {
                    final hasCategory = gigCategory != null && gigCategory.isNotEmpty;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (hasCategory) ...[
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                gigCategory,
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                        ],
                        Expanded(
                          flex: hasCategory ? 3 : 1,
                          child: Text(
                            'From \$${pull.priceUpdate.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}