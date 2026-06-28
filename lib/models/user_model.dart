  class UserModel {
    final String id;
    final String username;
    final String email;
    final String bio;
    final String profileImage;
    final int postsCount;
    final int followersCount;
    final int followingCount;
    final bool isVerified;

    UserModel({
      required this.id,
      required this.username,
      required this.email,
      required this.bio,
      required this.profileImage,
      required this.postsCount,
      required this.followersCount,
      required this.followingCount,
      this.isVerified = false,
    });

    // Mock Data
    static UserModel currentUser = UserModel(
      id: '1',
      username: 'fraz_ali',
      email: 'fraz@petconnect.com',
      bio: 'user bio goes here..',
      profileImage: 'https://via.placeholder.com/150',
      postsCount: 0,
      followersCount: 0,
      followingCount: 0,
    );

    static List<UserModel> mockUsers = [
      UserModel(
        id: '2',
        username: 'bhaggabilla',
        email: 'bhagga@petconnect.com',
        bio: 'Cat lover 🐱',
        profileImage: 'https://via.placeholder.com/150',
        postsCount: 45,
        followersCount: 2500,
        followingCount: 320,
      ),
      UserModel(
        id: '3',
        username: 'catbuddy',
        email: 'catbuddy@petconnect.com',
        bio: 'Professional pet photographer 📸',
        profileImage: 'https://via.placeholder.com/150',
        postsCount: 120,
        followersCount: 5400,
        followingCount: 890,
      ),
      UserModel(
        id: '4',
        username: 'pawsome_pets',
        email: 'pawsome@petconnect.com',
        bio: 'All things cute and furry 🐾',
        profileImage: 'https://via.placeholder.com/150',
        postsCount: 89,
        followersCount: 3200,
        followingCount: 450,
      ),
    ];
  }
