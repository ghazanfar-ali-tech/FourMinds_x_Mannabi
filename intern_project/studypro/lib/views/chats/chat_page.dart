import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:studypro/components/appColor.dart';
import 'package:studypro/components/size_config.dart';
import 'package:studypro/providers/chat_providers/chat_provider.dart';
import 'package:studypro/providers/theme_provider.dart';

class ChatPage extends StatefulWidget {
  final Map<String, dynamic> userMap;
  final String chatId;

  ChatPage({required this.chatId, required this.userMap});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final TextEditingController messageController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  bool _isMessageEmpty = true;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
    messageController.addListener(_onMessageChanged);
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _scrollController.dispose();
    messageController.dispose();
    super.dispose();
  }

  void _onMessageChanged() {
    final isEmpty = messageController.text.trim().isEmpty;
    if (isEmpty != _isMessageEmpty) {
      setState(() => _isMessageEmpty = isEmpty);
      if (isEmpty) {
        _fabAnimationController.reverse();
      } else {
        _fabAnimationController.forward();
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void onSendMessage(ChatProvider chatProvider) async {
    if (messageController.text.isNotEmpty) {
      if (chatProvider.isEditing) {
        try {
          await _firestore
              .collection('chatRooms')
              .doc(widget.chatId)
              .collection('chats')
              .doc(chatProvider.editingMessageKey)
              .update({
            'message': messageController.text.trim(),
            'isUpdated': true,
          });
          chatProvider.stopEditing();
          messageController.clear();
        } catch (e) {
          print('Update Error: $e');
          _showErrorSnackBar('Failed to update message');
        }
      } else {
        try {
          Map<String, dynamic> messages = {
            'sendBy': auth.currentUser!.uid,
            'message': messageController.text.trim(),
            'time': FieldValue.serverTimestamp(),
          };

          messageController.clear();
          await _firestore
              .collection('chatRooms')
              .doc(widget.chatId)
              .collection('chats')
              .add(messages);

          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        } catch (e) {
          print('Send Message Error: $e');
          _showErrorSnackBar('Failed to send message');
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildShimmerMessage({bool isMe = false}) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Shimmer.fromColors(
        baseColor: themeProvider.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
        highlightColor: themeProvider.isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: SizeConfig().scaleHeight(16, context), 
                width: double.infinity, 
                color: Colors.white),
               SizedBox(height: SizeConfig().scaleHeight(4, context)),
              Container(
                height: SizeConfig().scaleHeight(12, context), 
                width: SizeConfig().scaleWidth(60, context), 
                color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble({
    required Map<String, dynamic> message,
    required String messageKey,
    required bool isMe,
    required String formattedTime,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Container(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: isMe
              ? LinearGradient(
                  colors: themeProvider.isDarkMode
                      ? [AppColors.primary.withOpacity(0.8), AppColors.primaryDark]
                      : [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isMe ? null : AppColors.cardBackground(context),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow(context),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: isMe
              ? null
              : Border.all(
                  color: AppColors.border(context).withOpacity(0.3),
                  width: 1,
                ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onLongPress: () => _showMessageOptions(context, message, messageKey, isMe),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['message'] ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      color: isMe ? Colors.white : AppColors.textPrimary(context),
                      height: 1.3,
                    ),
                  ),
                   SizedBox(height: SizeConfig().scaleHeight(4, context)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formattedTime,
                        style: TextStyle(
                          fontSize: 11,
                          color: isMe
                              ? Colors.white.withOpacity(0.8)
                              : AppColors.textSecondary(context),
                        ),
                      ),
                      if (message['isUpdated'] == true) ...[
                         SizedBox(width: SizeConfig().scaleWidth(4, context)),
                        Icon(
                          Icons.edit,
                          size: 12,
                          color: isMe
                              ? Colors.white.withOpacity(0.8)
                              : AppColors.textSecondary(context),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSeparator(String date) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.cardBackground(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.border(context).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow(context),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          date,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary(context),
          ),
        ),
      ),
    );
  }

  void _showMessageOptions(BuildContext context, Map<String, dynamic> message, String messageKey, bool isMyMessage) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground(context),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             SizedBox(height: SizeConfig().scaleHeight(8, context)),
            Container(
              width: SizeConfig().scaleWidth(40, context),
              height: SizeConfig().scaleHeight(4, context),
              decoration: BoxDecoration(
                color: AppColors.border(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
             SizedBox(height: SizeConfig().scaleHeight(16, context)),
            if (isMyMessage) ...[
              _buildBottomSheetItem(
                icon: Icons.edit,
                title: 'Edit Message',
                onTap: () {
                  Navigator.pop(context);
                  chatProvider.startEditing(messageKey, message['message']);
                  messageController.text = message['message'];
                },
              ),
            ],
            _buildBottomSheetItem(
              icon: Icons.delete,
              title: 'Delete Message',
              color: AppColors.error,
              onTap: () => _deleteMessage(context, messageKey),
            ),
             SizedBox(height: SizeConfig().scaleHeight(16, context)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.iconPrimary),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? AppColors.textPrimary(context),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Future<void> _deleteMessage(BuildContext context, String messageKey) async {
    Navigator.pop(context);
    try {
      await _firestore
          .collection('chatRooms')
          .doc(widget.chatId)
          .collection('chats')
          .doc(messageKey)
          .delete();
    } catch (e) {
      print('Delete Error: $e');
      _showErrorSnackBar('Failed to delete message');
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userName = widget.userMap['username'] ?? widget.userMap['firstName'] ?? 'Unknown';
    final profilePhotoUrl = (widget.userMap['profilePhotoUrl'] ?? '').toString();
    final firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

  Widget avatar;
  if (profilePhotoUrl.isNotEmpty) {
    avatar = Container(
      width: SizeConfig().scaleWidth(50, context),
      height: SizeConfig().scaleHeight(50, context),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: NetworkImage(profilePhotoUrl),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  } else {
    avatar = Container(
      width: SizeConfig().scaleWidth(50, context),
      height: SizeConfig().scaleHeight(50, context),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: themeProvider.isDarkMode
              ? [AppColors.primary.withOpacity(0.8), AppColors.primaryDark]
              : [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          firstLetter,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: themeProvider.isDarkMode
                ? [const Color.fromARGB(255, 32, 32, 32), const Color.fromARGB(255, 48, 48, 48)]
                : [Colors.blue, Colors.black],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    Container(
                      width: SizeConfig().scaleWidth(40, context),
                      height: SizeConfig().scaleHeight(40, context),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: avatar,
                      ),
                    ),
                     SizedBox(width: SizeConfig().scaleWidth(12, context)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                         
                        ],
                      ),
                    ),
                   
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background(context),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Consumer<ChatProvider>(
                    builder: (context, chatProvider, child) {
                      return Column(
                        children: [
                  
                          if (chatProvider.isEditing)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                border: Border(
                                  bottom: BorderSide(
                                    color: AppColors.border(context).withOpacity(0.3),
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 16, color: AppColors.primary),
                                   SizedBox(width: SizeConfig().scaleWidth(8, context)),
                                  Text(
                                    'Editing message',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      chatProvider.stopEditing();
                                      messageController.clear();
                                    },
                                    child: Icon(Icons.close, size: 18, color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                          Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: _firestore
                                  .collection('chatRooms')
                                  .doc(widget.chatId)
                                  .collection('chats')
                                  .orderBy('time', descending: false)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return ListView.builder(
                                    itemCount: 8,
                                    itemBuilder: (context, index) => _buildShimmerMessage(
                                      isMe: index % 3 == 0,
                                    ),
                                  );
                                }
                                
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.error_outline, size: 48, color: AppColors.error),
                                         SizedBox(height: SizeConfig().scaleHeight(16, context)),
                                        Text(
                                          'Error loading messages',
                                          style: TextStyle(color: AppColors.textSecondary(context)),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                
                                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.iconSecondary(context)),
                                         SizedBox(height: SizeConfig().scaleHeight(16, context)),
                                        Text(
                                          'No messages yet',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textSecondary(context),
                                          ),
                                        ),
                                         SizedBox(height: SizeConfig().scaleHeight(8, context)),
                                        Text(
                                          'Start the conversation!',
                                          style: TextStyle(color: AppColors.textSecondary(context)),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                
                                final messageList = snapshot.data!.docs
                                    .map((doc) => {
                                          'key': doc.id,
                                          'data': doc.data() as Map<String, dynamic>?,
                                        })
                                    .where((map) => map['data'] != null)
                                    .toList();
                                
                                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                                
                                return ListView.builder(
                                  controller: _scrollController,
                                  itemCount: messageList.length,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  itemBuilder: (context, index) {
                                    final messageData = messageList[index]['data'] as Map<String, dynamic>;
                                    final messageKey = messageList[index]['key'] as String;
                                    final isMe = messageData['sendBy'] == auth.currentUser?.uid;
                                    
                                    final messageTime = messageData['time'] != null
                                        ? (messageData['time'] as Timestamp).toDate()
                                        : DateTime.now();
                                    
                                    final formattedTime = _formatTime(messageTime);
                                    final formattedDate = '${messageTime.day}-${messageTime.month}-${messageTime.year}';
                                    
                                    bool showDateSeparator = true;
                                    if (index > 0) {
                                      final previousMessageData = messageList[index - 1]['data'] as Map<String, dynamic>;
                                      final previousMessageTime = previousMessageData['time'] != null
                                          ? (previousMessageData['time'] as Timestamp).toDate()
                                          : DateTime.now();
                                      final previousFormattedDate = '${previousMessageTime.day}-${previousMessageTime.month}-${previousMessageTime.year}';
                                      if (formattedDate == previousFormattedDate) {
                                        showDateSeparator = false;
                                      }
                                    }
                                    
                                    return Column(
                                      children: [
                                        if (showDateSeparator) _buildDateSeparator(formattedDate),
                                        _buildMessageBubble(
                                          message: messageData,
                                          messageKey: messageKey,
                                          isMe: isMe,
                                          formattedTime: formattedTime,
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background(context),
                  border: Border(
                    top: BorderSide(
                      color: AppColors.border(context).withOpacity(0.3),
                    ),
                  ),
                ),
                child: Consumer<ChatProvider>(
                  builder: (context, chatProvider, child) {
                    return Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground(context),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: AppColors.border(context).withOpacity(0.3),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadow(context),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: messageController,
                              maxLines: 4,
                              minLines: 1,
                              style: TextStyle(color: AppColors.textPrimary(context)),
                              decoration: InputDecoration(
                                hintText: chatProvider.isEditing ? 'Edit message...' : 'Type a message...',
                                hintStyle: TextStyle(color: AppColors.textSecondary(context)),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              onSubmitted: (_) => onSendMessage(chatProvider),
                            ),
                          ),
                        ),
                         SizedBox(width: SizeConfig().scaleWidth(12, context)),
                        ScaleTransition(
                          scale: _fabAnimation,
                          child: Container(
                            width: SizeConfig().scaleWidth(48, context),
                            height: SizeConfig().scaleHeight(48, context),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: _isMessageEmpty ? null : () => onSendMessage(chatProvider),
                                child: Center(
                                  child: Icon(
                                    chatProvider.isEditing ? Icons.check : Icons.send,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}