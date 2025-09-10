import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../model/Women/buildWomenProductCard.dart';
import '../../../viewModel/Women/WomenViewModel.dart';
import '../../home/homeScreen.dart';

// Ethnic Wear View
class EthnicWearView extends StatelessWidget {
  const EthnicWearView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EthnicWearController controller = Get.put(EthnicWearController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return buildErrorWidget(controller.error.value, controller.retryLoading);
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ethnic Wear',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Traditional & Contemporary Indian Wear',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Products Grid
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: controller.WomenProducts.isEmpty
                    ? buildEmptyWidget()
                    : GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: controller.WomenProducts.length,
                  itemBuilder: (context, index) {
                    return buildWomenProductCard(controller.WomenProducts[index]);
                  },
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }
}

// Top Wear View
class TopWearView extends StatelessWidget {
  const TopWearView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TopWearController controller = Get.put(TopWearController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return buildErrorWidget(controller.error.value, controller.retryLoading);
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Wear',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Stylish Tops, Shirts & More',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Products Grid
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: controller.WomenProducts.isEmpty
                    ? buildEmptyWidget()
                    : GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: controller.WomenProducts.length,
                  itemBuilder: (context, index) {
                    return buildWomenProductCard(controller.WomenProducts[index]);
                  },
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }
}

// Bottom Wear View
class BottomWearView extends StatelessWidget {
  const BottomWearView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BottomWearController controller = Get.put(BottomWearController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return buildErrorWidget(controller.error.value, controller.retryLoading);
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bottom Wear',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Jeans, Trousers, Skirts & More',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: controller.WomenProducts.isEmpty
                    ? buildEmptyWidget()
                    : GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: controller.WomenProducts.length,
                  itemBuilder: (context, index) {
                    return buildWomenProductCard(controller.WomenProducts[index]);
                  },
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }
}

// Jumpsuits View
class JumpsuitsView extends StatelessWidget {
  const JumpsuitsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final JumpsuitsController controller = Get.put(JumpsuitsController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return buildErrorWidget(controller.error.value, controller.retryLoading);
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jumpsuits',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'One-Piece Wonder Collection',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: controller.WomenProducts.isEmpty
                    ? buildEmptyWidget()
                    : GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: controller.WomenProducts.length,
                  itemBuilder: (context, index) {
                    return buildWomenProductCard(controller.WomenProducts[index]);
                  },
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }
}

// Maternity View
class MaternityView extends StatelessWidget {
  const MaternityView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MaternityController controller = Get.put(MaternityController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return buildErrorWidget(controller.error.value, controller.retryLoading);
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Maternity',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Comfortable Maternity & Nursing Wear',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: controller.WomenProducts.isEmpty
                    ? buildEmptyWidget()
                    : GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: controller.WomenProducts.length,
                  itemBuilder: (context, index) {
                    return buildWomenProductCard(controller.WomenProducts[index]);
                  },
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }
}

// Sleep Wear View
class SleepWearView extends StatelessWidget {
  const SleepWearView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SleepWearController controller = Get.put(SleepWearController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return buildErrorWidget(controller.error.value, controller.retryLoading);
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sleep Wear',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Comfortable Night & Lounge Wear',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: controller.WomenProducts.isEmpty
                    ? buildEmptyWidget()
                    : GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: controller.WomenProducts.length,
                  itemBuilder: (context, index) {
                    return buildWomenProductCard(controller.WomenProducts[index]);
                  },
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }
}

// Winter Wear View
class WinterWearView extends StatelessWidget {
  const WinterWearView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final WinterWearController controller = Get.put(WinterWearController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return buildErrorWidget(controller.error.value, controller.retryLoading);
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Winter Wear',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Warm & Cozy Winter Collection',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: controller.WomenProducts.isEmpty
                    ? buildEmptyWidget()
                    : GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: controller.WomenProducts.length,
                  itemBuilder: (context, index) {
                    return buildWomenProductCard(controller.WomenProducts[index]);
                  },
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }
}

// Active Wear View
class ActiveWearView extends StatelessWidget {
  const ActiveWearView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ActiveWearController controller = Get.put(ActiveWearController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return buildErrorWidget(controller.error.value, controller.retryLoading);
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Wear',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Fitness & Sports Collection',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: controller.WomenProducts.isEmpty
                    ? buildEmptyWidget()
                    : GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: controller.WomenProducts.length,
                  itemBuilder: (context, index) {
                    return buildWomenProductCard(controller.WomenProducts[index]);
                  },
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }
}

// Inner Wear View
class InnerWearView extends StatelessWidget {
  const InnerWearView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final InnerWearController controller = Get.put(InnerWearController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return buildErrorWidget(controller.error.value, controller.retryLoading);
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inner Wear',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Intimate & Essential Collection',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: controller.WomenProducts.isEmpty
                    ? buildEmptyWidget()
                    : GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: controller.WomenProducts.length,
                  itemBuilder: (context, index) {
                    return buildWomenProductCard(controller.WomenProducts[index]);
                  },
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }
}