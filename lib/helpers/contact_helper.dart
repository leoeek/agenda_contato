import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

const String contactTable = 'contactTable';
const String idColumn = 'idColumn';
const String nameColumn = 'nameColumn';
const String emailColumn = 'emailColumn';
const String phoneColumn = 'phoneColumn';
const String imgColumn = 'imgColumn';

class ContactHelper {
  // ContactHelper.internal();

  static final ContactHelper instance = ContactHelper._instance();
  
  // factory ContactHelper() => _instance;

  static Database? _db = null;
  ContactHelper._instance();

  Future<Database?> get db async {
    if (_db == null) {
      _db = await initDb();
    }

    return _db;
  }

  Future<Database> initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + "contacts_new.db";

    // await deleteDatabase(path);

    final myDB = await openDatabase(
      path,
      version: 3,
      onCreate: _createDb,
    );

    return myDB;
  }

  void _createDb(Database db, int version) async {
    print('vai criar');
    await db.execute(
      "CREATE TABLE $contactTable ($idColumn INTEGER PRIMARY KEY AUTOINCREMENT, $nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imgColumn TEXT)"
    );
  }

  Future<Contact> saveContact(Contact contact) async {
    Database? dbContact = await this.db;
    contact.id = await dbContact!.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact?> getContact(int id) async {
    Database? dbContact = await this.db;
    List<Map> maps = await dbContact!.query(
      contactTable,
      columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
      where: "$idColumn = ?",
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteContact(int id) async {
    Database? dbContact = await this.db;
    return await dbContact!.delete(
      contactTable,
      where: "$idColumn = ?",
      whereArgs: [id],
    );
  }

  updateContact(Contact contact) async {
    Database? dbContact = await this.db;
    return await dbContact!.update(
      contactTable,
      contact.toMap(),
      where: "$idColumn = ?",
      whereArgs: [contact.id],
    );
  }

  Future<List<Map<String, dynamic>>> getContactsMapList() async {
    Database? dbContact = await this.db;
    final List<Map<String, dynamic>> result = await dbContact!.query(contactTable);
    return result;
  }


  Future<List<Contact>> getAllContacts() async {
    final List<Map<String, dynamic>> contactMapList = await getContactsMapList();
    final List<Contact> contactList = [];

    contactMapList.forEach((conctactMap) {
      contactList.add(Contact.fromMap(conctactMap));
    });

    return contactList;
  }

  Future<int> getNumber() async {
    Database? dbContact = await this.db;
    return Sqflite.firstIntValue(
        await dbContact!.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  Future close() async {
    Database? dbContact = await this.db;
    dbContact!.close();
  }
}

class Contact {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? img;

  Contact();

  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };

    if (id != null) {
      map[idColumn] = id;
    }

    return map;
  }

  @override
  String toString() {
    return "Conctac(id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }
}
