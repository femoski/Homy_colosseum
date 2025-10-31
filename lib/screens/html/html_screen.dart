import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../utils/html_type.dart';
import 'controllers/html_controller.dart';

class HtmlViewerScreen extends StatefulWidget {
  final HtmlType htmlType;
  const HtmlViewerScreen({super.key, required this.htmlType});

  @override
  State<HtmlViewerScreen> createState() => _HtmlViewerScreenState();
}

class _HtmlViewerScreenState extends State<HtmlViewerScreen> {

  @override
  void initState() {
    super.initState();
    
    // Initialize and fetch HTML text
    final controller = Get.put(HtmlController());
    controller.getHtmlText(widget.htmlType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.htmlType == HtmlType.termsAndCondition ? 'Terms & Conditions'.tr
          : widget.htmlType == HtmlType.aboutUs ? 'About Us'.tr 
          : widget.htmlType == HtmlType.privacyPolicy ? 'Privacy Policy'.tr 
          : widget.htmlType == HtmlType.shippingPolicy ? 'Shipping Policy'.tr
          : widget.htmlType == HtmlType.refund ? 'Refund Policy'.tr 
          : widget.htmlType == HtmlType.cancellation ? 'Cancellation Policy'.tr 
          : 'no_data_found'.tr),
      ),
      body: GetBuilder<HtmlController>(builder: (htmlController) {
        if (htmlController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (htmlController.htmlText == null || htmlController.htmlText!.isEmpty) {
          return Center(
            child: Text(
              'No data found'.tr,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
              ),
            ),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: HtmlWidget(
                  htmlController.htmlText!,
                  key: Key(widget.htmlType.toString()),
                  textStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)),
                  onTapUrl: (String url) async {
                    return await launchUrlString(url);
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class WebScreenTitleWidget extends StatelessWidget {
  final String title;
  const WebScreenTitleWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return  Container(
      height: 64,
      color: Theme.of(context).primaryColor.withOpacity(0.10),
      child: Center(child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
    );
  }
}

