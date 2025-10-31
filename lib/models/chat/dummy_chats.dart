import 'package:homy/models/chat/chat_user.dart';
import 'package:homy/models/chat/conversation.dart';

List<Chat> getDummyChats() {
  return [
    Chat(
      timeId: 1,
      msgType: 1, // Text message
      message: "Hello! How are you?",
      senderUser: ChatUser(
        userID: 1,
        name: "John Doe",
        image: "assets/images/user1.png",
      ),
      notDeletedIdentity: [],
    ),
    Chat(
      timeId: 2,
      msgType: 1,
      message: "I'm doing great, thanks! How about you?",
      senderUser: ChatUser(
        userID: 2,
        name: "Jane Smith",
        image: "assets/images/user2.png",
      ),
      notDeletedIdentity: [],
    ),
    Chat(
      timeId: 3,
      msgType: 1,
      message: "I'm interested in the property you listed.",
      senderUser: ChatUser(
        userID: 1,
        name: "John Doe",
        image: "assets/images/user1.png",
      ),
      notDeletedIdentity: [],
    ),
    Chat(
      timeId: 4,
      msgType: 1,
      message: "Sure! Which property would you like to know more about?",
      senderUser: ChatUser(
        userID: 2,
        name: "Jane Smith",
        image: "assets/images/user2.png",
      ),
      notDeletedIdentity: [],
    ),
    // Example of a property message
    Chat(
      timeId: 5,
      msgType: 4, // Property message type
      senderUser: ChatUser(
        userID: 1,
        name: "John Doe",
        image: "assets/images/user1.png",
      ),
      propertyCard: PropertyMessage(
        propertyId: 123,
        title: "Luxury Downtown Apartment",
        propertyType: 1,
        address: "123 Downtown Street",
        message: "I'm interested in this property",
        image: ["assets/images/property1.jpg"],
      ),
      notDeletedIdentity: [],
    ),
    Chat(
      timeId: 6,
      msgType: 1,
      message: "Great choice! Would you like to schedule a viewing?",
      senderUser: ChatUser(
        userID: 2,
        name: "Jane Smith",
        image: "assets/images/user2.png",
      ),
      notDeletedIdentity: [],
    ),
  ].reversed.toList(); // Reversed because ChatArea shows messages in reverse order
} 