import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speed_co/layouts/user_layout/cubit/user_cubit.dart';
import 'package:speed_co/layouts/user_layout/cubit/user_states.dart';
import 'package:speed_co/modules/item_shared/default_button.dart';
import 'package:speed_co/shared/components/components.dart';
import 'package:speed_co/shared/components/constants.dart';
import 'package:speed_co/shared/images/images.dart';
import 'package:speed_co/shared/styles/colors.dart';
import '../menu_screens/menu_cubit/menu_cubit.dart';
import '../widgets/home/place_dialog.dart';
import '../widgets/menu/track_dialog.dart';

class PlaceOrderScreen extends StatefulWidget {
  PlaceOrderScreen(this.id);
  String id;
  @override
  State<PlaceOrderScreen> createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {


  int currentDay = 0;
  int currentTime = 0;
  PageController pageController = PageController();
  TextEditingController descController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserStates>(
  listener: (context, state) {
    if(state is PlaceOrderSuccessState)  showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context)=>TrackDialog()
    );
  },
  builder: (context, state) {
    var cubit = UserCubit.get(context);
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(Images.background,),
          Column(
            children: [
              defaultAppBar(context: context,haveLocation: true),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          tr('select_date_time'),
                          style: TextStyle(color: defaultColorTwo,fontWeight: FontWeight.w500),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  height: 605,
                                  child: PageView.builder(
                                    itemCount: 3,
                                    controller: pageController,
                                    itemBuilder:(c,i)=> ListView.separated(
                                        itemBuilder: (c,i)=>itemBuilder(i),
                                        physics: const NeverScrollableScrollPhysics(),
                                        separatorBuilder: (c,i)=>const SizedBox(height: 25,),
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        itemCount: 7
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 35,),
                              Expanded(
                                flex: 2,
                                child: ListView.separated(
                                    itemBuilder: (c,i)=>itemBuilder2(i),
                                    physics: const NeverScrollableScrollPhysics(),
                                    separatorBuilder: (c,i)=>const SizedBox(height: 25,),
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    itemCount: 7
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            InkWell(
                                onTap:(){
                                  pageController.nextPage(
                                      duration:const Duration(milliseconds: 500),
                                      curve: Curves.easeInBack
                                  );
                                },
                                child: Icon(Icons.arrow_back,color: defaultColor,size: 15,)
                            ),

                                Text(
                                  tr('next_week'),
                                  style: TextStyle(color: defaultColor),
                                ),
                              InkWell(
                                  onTap:(){
                                    pageController.previousPage(
                                        duration:const Duration(milliseconds: 500),
                                        curve: Curves.easeInBack
                                    );
                                    },
                                  child: Icon(Icons.arrow_forward,color: defaultColor,size: 15,)
                              ),
                          ],
                        ),
                        const SizedBox(height: 10,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadiusDirectional.circular(19),
                                ),
                                padding:const EdgeInsets.symmetric(horizontal: 30),
                                child:TextFormField(
                                  maxLines: 7,
                                  onChanged: (val){},
                                  controller: descController,
                                  textInputAction: TextInputAction.done,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    hintText: tr('describe_problem'),
                                    hintStyle: TextStyle(color: defaultColorTwo,fontSize: 12)
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20,),
                            InkWell(
                              onTap: (){
                                cubit.selectImages();
                              },
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: defaultColor,
                                child: Image.asset(Images.uploadImage,width: 16,height: 15,),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 20,),
                        if(cubit.images.isNotEmpty)
                          imagesBuilder(cubit.images[0]),
                        if(cubit.images.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: GridView.builder(
                              itemBuilder: (c,i)=>imagesBuilder(cubit.images[i+1]),
                              padding: EdgeInsetsDirectional.zero,
                              physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                              itemCount: cubit.images.length -1,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              childAspectRatio: size!.width / (size!.height / 1.9),
                            ),
                          ),
                        ),
                        state is! PlaceOrderLoadingState ?
                        DefaultButton(
                            text: tr('confirm_request'),
                            onTap: (){
                              var menuCubit = MenuCubit.get(context);
                              if (cubit.latController.text.isNotEmpty){
                                cubit.placeOrder(
                                  lng: cubit.lngController.text,
                                  lat: cubit.latController.text,
                                  desc:descController.text.isNotEmpty? descController.text:null,
                                  id: widget.id
                                );
                              }else if(MenuCubit.get(context).userModel!=null){
                                if(menuCubit.userModel!.data!.currentLongitude!.isNotEmpty){
                                  cubit.placeOrder(
                                    lng: menuCubit.userModel!.data!.currentLongitude.toString(),
                                    lat: menuCubit.userModel!.data!.currentLatitude.toString(),
                                    desc:descController.text.isNotEmpty? descController.text:null,
                                    id: widget.id
                                  );
                                }else{
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context)=>PlaceOrderDialog()
                                  );
                                }
                              }else{
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context)=>PlaceOrderDialog()
                                );
                              }

                            }
                        ):const Center(child: CircularProgressIndicator(),)
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  },
);
  }

  Widget itemBuilder(int index){
    return InkWell(
      onTap: (){
        setState(() {
          currentDay = index;
        });
      },
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          color: currentDay == index?defaultColor.withOpacity(.3):Colors.grey.shade200,
          border: Border.all(color:currentDay == index?defaultColor:Colors.grey),
          borderRadius: BorderRadiusDirectional.circular(12)
        ),
        padding: EdgeInsets.symmetric(horizontal: 20),
        alignment: AlignmentDirectional.centerStart,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Today',
              style: TextStyle(
                color: Colors.black,fontWeight: FontWeight.w500
              ),
            ),
            Text(
              'Feb 04',
              style: TextStyle(
                color: Colors.grey.shade700,fontWeight: FontWeight.w500,fontSize: 10
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget itemBuilder2(int index){
    return InkWell(
      onTap: (){
        setState(() {
          currentTime = index;
        });
      },
      child: Container(
        height: 65,
        decoration: BoxDecoration(
            color: currentTime == index?defaultColor.withOpacity(.3):Colors.grey.shade200,
            border: Border.all(color:currentTime == index?defaultColor:Colors.grey),
          borderRadius: BorderRadiusDirectional.circular(12)
        ),
        padding:const EdgeInsets.symmetric(horizontal: 20),
        alignment: AlignmentDirectional.centerStart,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              tr('between'),
              style:const TextStyle(
                color: Colors.black,fontWeight: FontWeight.w300,fontSize: 10.3
              ),
            ),
            Text(
              '05:00 pm - 06:00 pm',
              style: TextStyle(
                color: Colors.grey.shade700,fontWeight: FontWeight.w500,fontSize: 10
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget imagesBuilder(XFile file){
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 160,width:double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadiusDirectional.circular(10),
            color: Colors.grey.shade200
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Image.file(File(file.path),fit: BoxFit.cover,),
        ),
        IconButton(
            onPressed: (){
              UserCubit.get(context).images.remove(file);
              UserCubit.get(context).emitState();
            },
            icon:const Icon(Icons.delete,color: Colors.red,size: 35,)
        )
      ],
    );
  }
}
