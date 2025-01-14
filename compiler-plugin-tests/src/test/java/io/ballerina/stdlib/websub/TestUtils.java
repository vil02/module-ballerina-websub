/*
 * Copyright (c) 2022 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package io.ballerina.stdlib.websub;

import io.ballerina.projects.Package;
import io.ballerina.projects.ProjectEnvironmentBuilder;
import io.ballerina.projects.directory.BuildProject;
import io.ballerina.projects.environment.Environment;
import io.ballerina.projects.environment.EnvironmentBuilder;
import io.ballerina.tools.text.LinePosition;
import io.ballerina.tools.text.LineRange;

import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * {@code TestUtils} contains the utility methods for compiler plugin tests.
 */
public final class TestUtils {
    private static final Path RESOURCE_PATH = Paths.get("src", "test", "resources");
    private static final Path DISTRIBUTION_PATH = Paths
            .get("../", "target", "ballerina-runtime").toAbsolutePath();

    public static Path getResourcePath(String baseDir, String packageName, String fileName) {
        return RESOURCE_PATH.resolve(baseDir).resolve(packageName).resolve(fileName);
    }

    public static Package loadPackage(String path) {
        Path projectDirPath = RESOURCE_PATH.resolve("ballerina_sources").resolve(path);
        BuildProject project = BuildProject.load(getEnvironmentBuilder(), projectDirPath);
        return project.currentPackage();
    }

    public static ProjectEnvironmentBuilder getEnvironmentBuilder() {
        Environment environment = EnvironmentBuilder.getBuilder().setBallerinaHome(DISTRIBUTION_PATH).build();
        return ProjectEnvironmentBuilder.getBuilder(environment);
    }

    public static boolean isWithinRange(LineRange lineRange, LinePosition pos) {
        int sLine = lineRange.startLine().line();
        int sCol = lineRange.startLine().offset();
        int eLine = lineRange.endLine().line();
        int eCol = lineRange.endLine().offset();

        return ((sLine == eLine && pos.line() == sLine) &&
                (pos.offset() >= sCol && pos.offset() <= eCol)
        ) || ((sLine != eLine) && (pos.line() > sLine && pos.line() < eLine ||
                pos.line() == eLine && pos.offset() <= eCol ||
                pos.line() == sLine && pos.offset() >= sCol
        ));
    }
}
