#!/bin/sh
exec scala -savecompiled "$0" "$@"
!#
import java.io.{PrintWriter, File}
import scala.sys.process._

/**
 * Created with IntelliJ IDEA.
 * User: marchaubenstock
 * Date: 30/12/2013
 * Time: 18:50
 */
object myScript {


  //****UTILS*****//

  trait exec {

    def exec() : Unit

  }

  abstract class destinationPath(){

    protected var project_destination = "/Users/marchaubenstock/workspace/typescript/"

  }

  class errorExec() extends destinationPath() with exec {

    def exec() : Unit = { println("No project path given"); sys.exit(1) }

  }

  class standardExec(private val project_dir : String) extends destinationPath() with exec {

    val newFile : String = "/Main.ts"

    project_destination = project_destination.concat(project_dir)
    val source_libs_dir : String = project_destination.concat("/src/libs")
    val build_libs_dir : String = project_destination.concat("/build/libs")
    val ( path_for_file , _ ) = source_libs_dir.splitAt(source_libs_dir.length-5)

    def makeDirectories(dest : String) : standardExec = {

      val new_file_path : String = path_for_file.concat(newFile)
      val lib_ref = "///<reference path=\'./libs/lib.d.ts\'/>\n"
      val phaser_ref = "///<reference path=\'./libs/phaser.d.ts\'/>\n"
      val jquery_ref = "///<reference path=\'.libs/jquery.d.ts\'/>\n"
      var references_list : List[String]= List(lib_ref,phaser_ref,jquery_ref)


      new File(source_libs_dir).mkdirs()
      new File(build_libs_dir).mkdirs()
      var new_file_ref : java.io.File = new File(new_file_path)
      new_file_ref.createNewFile()

      val content : String = references_list.foldLeft("")((acc, rest) =>  acc.concat(rest))
      val writer = new PrintWriter(new_file_ref)
      writer.write(content)
      writer.close()

      this
    }

    def thenCopyTemplates() : standardExec = {

      val grunt : String = "/Users/marchaubenstock/workspace/Utils/temps/GruntFile.js"
      val package_json : String = "/Users/marchaubenstock/workspace/Utils/temps/package.json"
      val node_modules_dir : String = "/Users/marchaubenstock/workspace/Utils/temps/node_modules"


      val defs_dir : String = "/Users/marchaubenstock/workspace/Utils/typescript_def/"
      val phaser_min_js : String = "/Users/marchaubenstock/workspace/Utils/phaser/build/phaser.min.js"


      val copy_command : String = "cp"
      val copy_dir_command :String = "cp -rf"

      // Copy Aux Files

      printf(s"$copy_command $grunt $project_destination".!!)
      printf(s"$copy_command $package_json $project_destination".!!)
      printf(s"$copy_dir_command $node_modules_dir $project_destination".!!)

      // Copy typescript definition files

      val defs_list : List[String] = List(defs_dir.concat("jquery.d.ts"),defs_dir.concat("lib.d.ts"),defs_dir.concat("phaser.d.ts"))

      defs_list.foreach(def_file => printf(s"$copy_command $def_file $source_libs_dir".!!))

      // Copy actual javascript files

      println(s"$copy_command $phaser_min_js $build_libs_dir".!!)

      // Copy HTML temp

      val html_temp : String = "/Users/marchaubenstock/workspace/Utils/temps/index.html"
      val build_dir : String = project_destination.concat("/build")

      printf(s"$copy_command $html_temp $build_dir".!!)

      this

    }
    //Remove any trailing slash "/"
    def removeTrailingSlash() : String = {

      if(project_destination.endsWith("/"))
         project_destination.substring(project_destination.length-1)
      else
        project_destination

    }

    def thenDone(): Unit = {println("Done")}

    def exec() : Unit = {


      makeDirectories(removeTrailingSlash()).thenCopyTemplates().thenDone()

    }

  }

  //****UTILS END*****//

  def main(args : Array[String]) : Unit = {

    var runner : exec = if (args.length > 0) new standardExec(args(0)) else new errorExec()

    runner.exec()


  }


}
