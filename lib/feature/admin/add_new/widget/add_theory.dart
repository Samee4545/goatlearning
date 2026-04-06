import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goatlearning/core/style/global_text_style.dart';
import 'package:goatlearning/feature/admin/add_new/controller/admin_add_new_controller.dart';

class AddTheory extends StatelessWidget {
  AddTheory({super.key});

  final AdminAddNewController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.cancel_outlined,
                    color: Color(0xff8AADDE),
                    size: 50,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/icons/download_icon.png", height: 48),

                  SizedBox(width: 12),
                  Text(
                    "Add Documents",
                    style: globalTextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Attach Documents", style: globalTextStyle()),
              ),

              SizedBox(height: 8),

              // DottedBorder(
              //   color: Color(0xff5EAEB5),
              //   dashPattern: [8, 4],
              //   strokeWidth: 1,
              //   borderType: BorderType.RRect,
              //   radius: Radius.circular(4),
              //   child: Obx(
              //     () => Container(
              //       height: 170,
              //       width: double.infinity,
              //       color: Color(0xFFF5F9FA),
              //       child:
              //           controller.image.value == null
              //               ? Column(
              //                 mainAxisAlignment: MainAxisAlignment.center,
              //                 children: [
              //                   GestureDetector(
              //                     onTap: () async {
              //                       await controller.pickImage();
              //                     },
              //                     child: Image.asset(
              //                       IconsPath.upload,
              //                       height: 24,
              //                       width: 24,
              //                     ),
              //                   ),
              //                   SizedBox(height: 12),
              //                   CustomText(
              //                     text: "Upload",
              //                     color: Color(0xff173156),
              //                     fontSize: 16,
              //                     fontWeight: FontWeight.w600,
              //                   ),
              //                 ],
              //               )
              //               : GestureDetector(
              //                 onTap: () async {
              //                   await controller.pickImage();
              //                 },
              //                 child: ClipRRect(
              //                   borderRadius: BorderRadius.circular(4),
              //                   child: Image.file(
              //                     controller.image.value!,
              //                     height: 166,
              //                     width: double.infinity,
              //                     fit: BoxFit.cover,
              //                   ),
              //                 ),
              //               ),
              //     ),
              //   ),
              // ),
              DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  color: Color(0xff5EAEB5),
                  dashPattern: [8, 4],
                  strokeWidth: 1,
                  radius: Radius.circular(4),
                  // borderType is implied by using RoundedRect*
                ),
                child: Obx(
                  () => Container(
                    height: 170,
                    width: double.infinity,
                    color: Color(0xFFF5F9FA),
                    child:
                        (controller.theoryFileName.value.isEmpty &&
                                controller.theoryPdfUrl.value.isEmpty)
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    await controller.pickPDF();
                                  },
                                  child: Icon(
                                    Icons.picture_as_pdf,
                                    size: 24,
                                    color: Color(0xff173156),
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  "Upload PDF",
                                  style: TextStyle(
                                    color: Color(0xff173156),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                            : GestureDetector(
                              onTap: () async {
                                await controller.pickPDF();
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.picture_as_pdf,
                                    size: 24,
                                    color: Color(0xff173156),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    controller.theoryFileName.value.isNotEmpty
                                        ? "File: ${controller.theoryFileName.value}"
                                        : "File: ${controller.theoryPdfUrl.value.split('/').last}",
                                    style: TextStyle(
                                      color: Color(0xff173156),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                  ),
                ),
              ),

              SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff5EAEB5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {},
                  child: Text(
                    "Upload",
                    style: globalTextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Color(0xff5EAEB5), width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {},
                  child: Text(
                    "Discard",
                    style: globalTextStyle(
                      fontSize: 16,
                      color: Color(0xff5EAEB5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
