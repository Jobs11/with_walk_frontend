import 'package:flutter/material.dart';
import 'package:with_walk/api/model/member.dart';
import 'package:with_walk/api/service/friend_service.dart';
import 'package:with_walk/api/service/member_service.dart';
import 'package:with_walk/views/widgets/user_profile_bottom_sheet.dart';

void showFollowerDialog(BuildContext context, String userId) {
  showDialog(
    context: context,
    builder: (context) => FollowerDialog(userId: userId),
  );
}

class FollowerDialog extends StatefulWidget {
  final String userId;

  const FollowerDialog({super.key, required this.userId});

  @override
  State<FollowerDialog> createState() => _FollowerDialogState();
}

class _FollowerDialogState extends State<FollowerDialog> {
  List<Member> followers = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFollowers();
  }

  Future<void> _loadFollowers() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final result = await FriendService.getFollowers(widget.userId);
      for (String id in result) {
        final user = await Memberservice.userdata(id);
        followers.add(user);
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
                  '팔로워',
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
                            onPressed: _loadFollowers,
                            child: const Text('다시 시도'),
                          ),
                        ],
                      ),
                    )
                  : followers.isEmpty
                  ? Center(
                      child: Text(
                        '팔로워가 없습니다',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: followers.length,
                      itemBuilder: (context, index) {
                        final user = followers[index];
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
