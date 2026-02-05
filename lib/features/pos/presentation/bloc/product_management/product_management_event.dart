part of 'product_management_bloc.dart';

sealed class ProductManagementEvent extends Equatable {
  const ProductManagementEvent();
  @override
  List<Object> get props => [];
}

class LoadAdminProducts extends ProductManagementEvent {}

class CreateProductEvent extends ProductManagementEvent {
  final String name;
  final double price;
  final String category;

  const CreateProductEvent({required this.name, required this.price, required this.category});
}

class UpdateProductEvent extends ProductManagementEvent {
  final Product product;
  const UpdateProductEvent(this.product);
}

class DeleteProductEvent extends ProductManagementEvent {
  final int id;
  const DeleteProductEvent(this.id);
}


class SaveRecipeEvent extends ProductManagementEvent {
  final int productId;
  final List<RecipeDTO> items;
  const SaveRecipeEvent(this.productId, this.items);
}