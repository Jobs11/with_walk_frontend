import 'package:flutter/material.dart';
import 'package:with_walk/api/model/member.dart';
import 'package:with_walk/api/service/friend_service.dart';
import 'package:with_walk/api/service/member_service.dart';
import 'package:with_walk/views/widgets/user_profile_bottom_sheet.dart';

void showFollowingDialog(BuildContext context, String userId) {
  showDialog(
    context: context,
    builder: (context) => FollowingDialog(userId: userId),
  );
}

class FollowingDialog extends StatefulWidget {
  final String userId;

  const FollowingDialog({super.key, required this.userId});

  @override
  State<FollowingDialog> createState() => _FollowingDialogState();
}

class _FollowingDialogState extends State<FollowingDialog> {
  List<Member> following = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFollowing();
  }

  Future<void> _loadFollowing() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final result = await FriendService.getFollowing(widget.userId);
      for (String id in result) {
        final user = await Memberservice.userdata(id);
        following.add(user);
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _showUserProfile(BuildContext context, String userId) async {
    final user = await Memberservice.userdata(userId);

    showModalBottomSheet(
      // ignore: use_build_context_synchronously
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => UserProfileBottomSheet(
        userId: userId,
        userName: user.mName,
        userImage: user.mProfileImage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '팔로잉',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '오류 발생',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            errorMessage!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadFollowing,
                            child: const Text('다시 시도'),
                          ),
                        ],
                      ),
                    )
                  : following.isEmpty
                  ? Center(
                      child: Text(
                        '팔로잉한 사용자가 없습니다',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: following.length,
                      itemBuilder: (context, index) {
                        final user = following[index];
                        return ListTile(
                          leading: Image.asset(
                            user.mProfileImage ??
                                'assets/images/icons/user.png',
                          ),
                          title: Text(user.mNickname),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                          ),
                          onTap: () {
                            _showUserProfile(context, user.mId);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
