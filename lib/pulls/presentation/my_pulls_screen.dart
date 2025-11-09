import 'package:flutter/material.dart';
import '../data/repository/pull_repository.dart';
import '../domain/model/pull.dart';
import '../../gigs/data/repository/gig_repository.dart';
import '../../gigs/domain/model/gig.dart';

class MyPullsScreen extends StatefulWidget {
  const MyPullsScreen({super.key});

  @override
  State<MyPullsScreen> createState() => _MyPullsScreenState();
}

class _MyPullsScreenState extends State<MyPullsScreen> {
  final _pullRepository = PullRepository();
  final _gigRepository = GigRepository();
  List<Pull> _pulls = [];
  Map<int, Gig> _gigsCache = {}; // Cache de gigs por gigId
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
      print('🔄 Iniciando carga de pulls para seller...');
      final pulls = await _pullRepository.getPullsBySellerId();
      print('📦 Pulls recibidos: ${pulls.length}');
      
      // Cargar información de los gigs para cada pull
      final gigsCache = <int, Gig>{};
      for (final pull in pulls) {
        try {
          print('📥 Cargando gig ${pull.gigId} para pull ${pull.id}...');
          final gig = await _gigRepository.getGigById(pull.gigId.toString());
          gigsCache[pull.gigId] = gig;
          print('✅ Gig ${pull.gigId} cargado: ${gig.title}');
        } catch (e) {
          // Si no se puede cargar el gig, continuar sin él
          print('⚠️ Error loading gig ${pull.gigId}: $e');
        }
      }

      print('✅ Carga completada. Pulls: ${pulls.length}, Gigs cargados: ${gigsCache.length}');
      setState(() {
        _pulls = pulls;
        _gigsCache = gigsCache;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('❌ Error al cargar pulls: $e');
      print('Stack trace: $stackTrace');
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
      case PullState.accepted:
        return 'Aceptado';
      case PullState.canceled:
        return 'Cancelado';
    }
  }

  Color _getStateColor(PullState state) {
    switch (state) {
      case PullState.pending:
        return Colors.orange;
      case PullState.accepted:
        return Colors.green;
      case PullState.canceled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pulls'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPulls,
          ),
        ],
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
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
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
                            // Header section
                            const Text(
                              'Today New Arivable',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Best of the today food list update.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Grid de 2 columnas
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.65,
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPullCard(Pull pull, Gig? gig) {
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
              child: (gig?.image != null && gig!.image!.isNotEmpty)
                  ? Image.network(
                      gig.image!,
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
                // Estado del pull
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStateColor(pull.state).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getStateText(pull.state),
                    style: TextStyle(
                      color: _getStateColor(pull.state),
                      fontWeight: FontWeight.w600,
                      fontSize: 8,
                    ),
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
                    final hasCategory = gig?.category != null && gig!.category!.isNotEmpty;
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
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                gig!.category!,
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

