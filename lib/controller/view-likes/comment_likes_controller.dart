import 'dart:async';
import 'package:flutter/material.dart';
import 'package:social_media_app/global_files.dart';

class CommentLikesController {
  BuildContext context;
  String commentID;
  ValueNotifier<LoadingState> loadingState = ValueNotifier(LoadingState.loading);
  ValueNotifier<List<String>> users = ValueNotifier([]);
  ValueNotifier<PaginationStatus> paginationStatus = ValueNotifier(PaginationStatus.loaded);
  ValueNotifier<bool> canPaginate = ValueNotifier(false);
  late StreamSubscription userDataStreamClassSubscription;
  ValueNotifier<bool> displayFloatingBtn = ValueNotifier(false);
  final ScrollController scrollController = ScrollController();

  CommentLikesController(
    this.context,
    this.commentID
  );

  bool get mounted => context.mounted;

  void initializeController(){
    runDelay(() async => fetchCommentsLikes(users.value.length, false), actionDelayTime);
    userDataStreamClassSubscription = UserDataStreamClass().userDataStream.listen((UserDataStreamControllerClass data) {
      if(mounted){
        if(data.uniqueID == commentID && data.actionType.name == UserDataStreamsUpdateType.addCommentLikes.name){
          if(!users.value.contains(data.userID)){
            users.value = [data.userID, ...users.value];
          }
        }
      }
    });
     scrollController.addListener(() {
      if(mounted){
        if(scrollController.position.pixels > animateToTopMinHeight){
          if(!displayFloatingBtn.value){
            displayFloatingBtn.value = true;
          }
        }else{
          if(displayFloatingBtn.value){
            displayFloatingBtn.value = false;
          }
        }
      }
    });
  }

  void dispose(){
    userDataStreamClassSubscription.cancel();
    loadingState.dispose();
    users.dispose();
    paginationStatus.dispose();
    canPaginate.dispose();
    displayFloatingBtn.dispose();
    scrollController.dispose();
  }

  Future<void> fetchCommentsLikes(int currentUsersLength, bool isRefreshing) async{
    if(mounted){
      dynamic res = await fetchDataRepo.fetchData(
        context, 
        RequestGet.fetchCommentLikes, 
        {
          'commentID': commentID,
          'currentID': appStateClass.currentID,
          'currentLength': currentUsersLength,
          'paginationLimit': usersPaginationLimit,
          'maxFetchLimit': usersServerFetchLimit
        }
      );
      if(mounted) {
        loadingState.value = LoadingState.loaded;
        if(res != null){
          List followersProfileDatasList = res.data['usersProfileData'];
          List followersSocialsDatasList = res.data['usersSocialsData'];
          if(isRefreshing){
            users.value = [];
          }
          canPaginate.value = res.data['canPaginate'];
          for(int i = 0; i < followersProfileDatasList.length; i++){
            Map userProfileData = followersProfileDatasList[i];
            UserDataClass userDataClass = UserDataClass.fromMap(userProfileData);
            UserSocialClass userSocialClass = UserSocialClass.fromMap(followersSocialsDatasList[i]);
            updateUserData(userDataClass);
            updateUserSocials(userDataClass, userSocialClass);
            users.value = [userProfileData['user_id'], ...users.value];
          }
        }
      }
    }
  }

  Future<void> loadMoreUsers() async{
    if(mounted){
      loadingState.value = LoadingState.paginating;
      paginationStatus.value = PaginationStatus.loading;
      Timer.periodic(const Duration(milliseconds: 1500), (Timer timer) async{
        timer.cancel();
        await fetchCommentsLikes(users.value.length, false);
        if(mounted){
          paginationStatus.value = PaginationStatus.loaded;
        }
      });
    }
  }
}