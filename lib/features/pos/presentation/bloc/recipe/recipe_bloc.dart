import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/database/app_database.dart';
import '../../../domain/repositories/product_repository.dart';
import '../../../../inventory/domain/repositories/inventory_repository.dart';

// --- EVENTOS ---
abstract class RecipeEvent extends Equatable {
  const RecipeEvent();
  @override
  List<Object> get props => [];
}

class LoadRecipe extends RecipeEvent {
  final int productId;
  const LoadRecipe(this.productId);
}

class SaveRecipe extends RecipeEvent {
  final int productId;
  final List<RecipeDTO> items;
  const SaveRecipe(this.productId, this.items);
}

// --- ESTADOS ---
abstract class RecipeState extends Equatable {
  const RecipeState();
  @override
  List<Object> get props => [];
}

class RecipeInitial extends RecipeState {}
class RecipeLoading extends RecipeState {}

class RecipeLoaded extends RecipeState {
  final Product product;
  final List<Ingredient> allIngredients;
  final List<RecipeDTO> currentRecipe;

  const RecipeLoaded({
    required this.product,
    required this.allIngredients,
    required this.currentRecipe,
  });

  @override
  List<Object> get props => [product, allIngredients, currentRecipe];
}

class RecipeError extends RecipeState {
  final String message;
  const RecipeError(this.message);
}

class RecipeSavedSuccess extends RecipeState {}

// --- BLOC ---
class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final ProductRepository _productRepo;
  final InventoryRepository _inventoryRepo;

  RecipeBloc(this._productRepo, this._inventoryRepo) : super(RecipeInitial()) {
    
    on<LoadRecipe>((event, emit) async {
      emit(RecipeLoading());
      try {
        // 1. Cargar Producto
        final allProducts = await _productRepo.getAllProducts();
        final product = allProducts.firstWhere((p) => p.id == event.productId);

        // 2. Cargar Ingredientes Disponibles
        final allIngredients = await _inventoryRepo.getInventoryStream().first;

        // 3. Cargar Receta Existente
        final recipe = await _productRepo.getProductRecipe(event.productId);

        emit(RecipeLoaded(
          product: product,
          allIngredients: allIngredients,
          currentRecipe: recipe,
        ));
      } catch (e) {
        emit(RecipeError("Error cargando receta: $e"));
      }
    });

    on<SaveRecipe>((event, emit) async {
      emit(RecipeLoading());
      try {
        await _productRepo.updateProductRecipe(event.productId, event.items);
        emit(RecipeSavedSuccess());
      } catch (e) {
        emit(RecipeError("Error guardando: $e"));
      }
    });
  }
}